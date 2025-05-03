import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { Database } from "@/lib/supabase/database.types";

type CountryType = Database["public"]["Enums"]["country"];

export async function GET(request: NextRequest) {
  try {
    // Get query parameters
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "10");
    // Make sort optional - we'll sort by latest chapters later
    const sort = searchParams.get("sort");
    const order = searchParams.get("order") || "desc";

    // Calculate offset
    const offset = (page - 1) * limit;

    // Build query for comics
    let query = supabaseAdmin.from("mKomik").select(
      `
        *,
        mChapter!mChapter_id_komik_fkey (count),
        trGenre!trGenre_id_komik_fkey (id_genre, mGenre!inner (id, name))
      `,
      { count: "exact" }
    );

    // Apply sorting only if explicitly specified
    if (sort) {
      query = query.order(sort, { ascending: order === "asc" });
    } else {
      // Default sorting by created_date desc to get newer comics first
      // We'll sort by latest chapters later in memory
      query = query.order("created_date", { ascending: false });
    }

    // Apply pagination
    query = query.range(offset, offset + limit - 1);

    // Execute query
    const { data: comicsData, error: comicsError, count } = await query;

    if (comicsError) {
      return NextResponse.json({ error: comicsError.message }, { status: 500 });
    }

    // Jika tidak ada comics, return empty data
    if (!comicsData || comicsData.length === 0) {
      return NextResponse.json({
        data: [],
        meta: {
          currentPage: page,
          totalPages: 0,
          totalItems: 0,
          itemsPerPage: limit,
        },
      });
    }

    // Transform data first to include genres as an array
    const transformedComics = comicsData.map((comic: any) => {
      // Extract genres from nested structure
      const genres =
        comic.trGenre && Array.isArray(comic.trGenre)
          ? comic.trGenre.map((genre: any) => genre.mGenre).filter(Boolean)
          : [];

      return {
        ...comic,
        // Format chapter count
        chapter_count:
          comic.mChapter && comic.mChapter[0]
            ? comic.mChapter[0].count || 0
            : 0,
        // Replace trGenre with formatted genres
        genres,
        // Initialize empty chapters array
        latest_chapters: [],
        // Remove unnecessary fields
        trGenre: undefined,
        mChapter: undefined,
      };
    });

    // Fetch the latest chapters for each comic individually using Promise.all for parallel execution
    // This ensures we get chapters for every comic that has them while being more efficient
    const comicsWithChapters = transformedComics.filter(
      (comic) => comic.chapter_count > 0
    );

    if (comicsWithChapters.length > 0) {
      await Promise.all(
        comicsWithChapters.map(async (comic) => {
          const { data: chaptersData, error: chaptersError } =
            await supabaseAdmin
              .from("mChapter")
              .select(
                "id, id_komik, chapter_number, release_date, thumbnail_image_url"
              )
              .eq("id_komik", comic.id)
              .not("chapter_number", "is", null)
              .order("chapter_number", { ascending: false })
              .limit(2);

          if (!chaptersError && chaptersData && chaptersData.length > 0) {
            comic.latest_chapters = chaptersData;
          }
        })
      );
    }

    // Sort by latest chapter release date if no explicit sort parameter was provided
    if (!sort) {
      transformedComics.sort((a, b) => {
        // Get the latest chapter for each comic
        const latestChapterA =
          a.latest_chapters && a.latest_chapters.length > 0
            ? a.latest_chapters[0]
            : null;
        const latestChapterB =
          b.latest_chapters && b.latest_chapters.length > 0
            ? b.latest_chapters[0]
            : null;

        // If both comics have chapters, compare their release dates
        if (latestChapterA && latestChapterB) {
          const dateA = new Date(latestChapterA.release_date || 0);
          const dateB = new Date(latestChapterB.release_date || 0);
          return dateB.getTime() - dateA.getTime(); // Descending order (newest first)
        }

        // If only one comic has chapters, prioritize that one
        if (latestChapterA) return -1;
        if (latestChapterB) return 1;

        // If neither has chapters, sort by comic creation date
        const comicDateA = new Date(a.created_date || 0);
        const comicDateB = new Date(b.created_date || 0);
        return comicDateB.getTime() - comicDateA.getTime(); // Descending order (newest first)
      });
    }

    // Return formatted response
    return NextResponse.json({
      data: transformedComics,
      meta: {
        currentPage: page,
        totalPages: Math.ceil((count || 0) / limit),
        totalItems: count || 0,
        itemsPerPage: limit,
      },
    });
  } catch (error) {
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
