import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@supabase/supabase-js";
import { supabaseAdmin } from "@/lib/supabase/client";
import { Database } from "@/lib/supabase/database.types";

// GET /api/comics/:id/complete - Get complete comic details with user data (chapters removed)
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    // Buat Supabase client langsung tanpa cookies
    const supabase = createClient<Database>(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );

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
      last_read_chapter: null as string | null,
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
        last_read_chapter: readingHistoryData?.id_chapter || null,
      };
    }

    // Increment view count
    await supabaseAdmin.rpc("increment_comic_view_count", { comic_id: id });

    // Return response with comic details and user data, but without chapters
    return NextResponse.json({
      comic: formattedComic,
      user_data: userData,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
