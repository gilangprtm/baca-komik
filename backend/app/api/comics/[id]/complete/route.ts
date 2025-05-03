import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";
import { supabaseAdmin } from "@/lib/supabase/client";

// GET /api/comics/:id/complete - Get complete comic details with chapters and user data
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const supabase = createClient(request);

    // Validate ID
    if (!id || typeof id !== "string") {
      return NextResponse.json({ error: "Invalid comic ID" }, { status: 400 });
    }

    // Check if user is authenticated
    const {
      data: { user },
    } = await supabase.auth.getUser();

    // Fetch comic with related data
    const { data: comicData, error: comicError } = await supabaseAdmin
      .from("mKomik")
      .select(
        `
        *,
        trGenre!trGenre_id_komik_fkey (
          mGenre!inner (id, name)
        ),
        trAuthor!trAuthor_id_komik_fkey (
          mAuthor!inner (id, name)
        ),
        trArtist!trArtist_id_komik_fkey (
          mArtist!inner (id, name)
        ),
        trFormat!trFormat_id_komik_fkey (
          mFormat!inner (id, name)
        )
      `
      )
      .eq("id", id)
      .single();

    if (comicError) {
      if (comicError.code === "PGRST116") {
        return NextResponse.json({ error: "Comic not found" }, { status: 404 });
      }
      return NextResponse.json({ error: comicError.message }, { status: 500 });
    }

    if (!comicData) {
      return NextResponse.json({ error: "Comic not found" }, { status: 404 });
    }

    // Fetch chapters for the comic with pagination
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "20");
    const sort = searchParams.get("sort") || "chapter_number";
    const order = searchParams.get("order") || "desc";

    // Calculate offset for pagination
    const offset = (page - 1) * limit;

    const { data: chaptersData, error: chaptersError, count } = await supabaseAdmin
      .from("mChapter")
      .select("*", { count: "exact" })
      .eq("id_komik", id)
      .order(sort, { ascending: order === "asc" })
      .range(offset, offset + limit - 1);

    if (chaptersError) {
      return NextResponse.json({ error: chaptersError.message }, { status: 500 });
    }

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    // Format comic data
    const formattedComic = {
      ...comicData,
      genres: comicData.trGenre.map((genre: any) => genre.mGenre),
      authors: comicData.trAuthor.map((author: any) => author.mAuthor),
      artists: comicData.trArtist.map((artist: any) => artist.mArtist),
      formats: comicData.trFormat.map((format: any) => format.mFormat),
      // Remove raw relationship data
      trGenre: undefined,
      trAuthor: undefined,
      trArtist: undefined,
      trFormat: undefined,
    };

    // Initialize user data
    let userData = {
      is_bookmarked: false,
      is_voted: false,
      last_read_chapter: null as string | null
    };

    // If user is authenticated, fetch user-specific data
    if (user) {
      // Check if comic is bookmarked
      const { data: bookmarkData } = await supabase
        .from("trUserBookmark")
        .select("id_komik")
        .eq("id_user", user.id)
        .eq("id_komik", id)
        .maybeSingle();

      // Check if comic is voted
      const { data: voteData } = await supabase
        .from("mKomikVote")
        .select("id_komik")
        .eq("id_user", user.id)
        .eq("id_komik", id)
        .maybeSingle();

      // Get last read chapter
      const { data: readingHistoryData } = await supabase
        .from("trUserHistory")
        .select("id_chapter")
        .eq("id_user", user.id)
        .eq("id_komik", id)
        .order("created_date", { ascending: false })
        .limit(1)
        .maybeSingle();

      userData = {
        is_bookmarked: !!bookmarkData,
        is_voted: !!voteData,
        last_read_chapter: readingHistoryData?.id_chapter || null
      };
    }

    // Increment view count
    await supabaseAdmin.rpc("increment_comic_view_count", { comic_id: id });

    // Return complete response
    return NextResponse.json({
      comic: formattedComic,
      chapters: {
        data: chaptersData,
        meta: {
          page,
          limit,
          total: count,
          total_pages: totalPages,
          has_more: page < totalPages,
        },
      },
      user_data: userData
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
