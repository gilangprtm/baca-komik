import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { createClient } from "@/lib/supabase/middleware";

// GET /api/bookmarks/details - Get user bookmarks with comic details and latest chapter
export async function GET(request: NextRequest) {
  try {
    const supabase = createClient(request);

    // Check if user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Get query parameters
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "10");

    // Calculate offset
    const offset = (page - 1) * limit;

    // Get bookmarks directly from supabase
    const bookmarksResult = await supabase
      .from("trUserBookmark")
      .select("*", { count: "exact" })
      .eq("id_user", user.id)
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

    if (bookmarksResult.error) {
      return NextResponse.json({ error: bookmarksResult.error.message }, { status: 500 });
    }

    const bookmarksData = bookmarksResult.data || [];
    const count = bookmarksResult.count || 0;

    if (bookmarksData.length === 0) {
      return NextResponse.json({
        data: [],
        meta: {
          page,
          limit,
          total: 0,
          total_pages: 0,
          has_more: false,
        },
      });
    }

    // Extract comic IDs
    const comicIds = bookmarksData.map(bookmark => bookmark.id_komik);

    // Get comic details
    const comicsResult = await supabase
      .from("mKomik")
      .select("*")
      .in("id", comicIds);

    if (comicsResult.error) {
      return NextResponse.json({ error: comicsResult.error.message }, { status: 500 });
    }

    const comicsData = comicsResult.data || [];

    // Create a map of comics by ID for quick lookup
    const comicsById: Record<string, any> = {};
    comicsData.forEach(comic => {
      comicsById[comic.id] = comic;
    });

    // Fetch latest chapter for each comic
    const chaptersResult = await supabaseAdmin
      .from("mChapter")
      .select("*")
      .in("id_komik", comicIds)
      .order("release_date", { ascending: false });

    if (chaptersResult.error) {
      return NextResponse.json({ error: chaptersResult.error.message }, { status: 500 });
    }

    const chaptersData = chaptersResult.data || [];

    // Group chapters by comic ID and get the latest one
    const latestChapterByComicId: Record<string, any> = {};
    chaptersData.forEach(chapter => {
      const comicId = chapter.id_komik;
      if (!latestChapterByComicId[comicId]) {
        latestChapterByComicId[comicId] = chapter;
      }
    });

    // Transform data to include comic details and latest chapter
    const transformedData = bookmarksData.map(bookmark => {
      const comic = comicsById[bookmark.id_komik];
      const latestChapter = latestChapterByComicId[bookmark.id_komik] || null;

      return {
        // Gunakan kombinasi id_user dan id_komik sebagai bookmark_id
        bookmark_id: `${bookmark.id_user}_${bookmark.id_komik}`,
        comic: comic ? {
          ...comic,
          latest_chapter: latestChapter
        } : null
      };
    }).filter(item => item.comic !== null);

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    return NextResponse.json({
      data: transformedData,
      meta: {
        page,
        limit,
        total: count,
        total_pages: totalPages,
        has_more: page < totalPages,
      },
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
