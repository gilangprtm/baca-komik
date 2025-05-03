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
      query = query.order('created_date', { ascending: false });
    }

    // Apply pagination
    query = query.range(offset, offset + limit - 1);

    // Execute query
    const { data: comicsData, error: comicsError, count } = await query;

    if (comicsError) {
      console.error("Error fetching comics:", comicsError);
      return NextResponse.json({ error: comicsError.message }, { status: 500 });
    }

    // Get comic IDs for fetching latest chapters
    const comicIds = comicsData?.map(comic => comic.id) || [];

    // Fetch latest chapters for all comics in one query
    const { data: chaptersData, error: chaptersError } = await supabaseAdmin
      .from("mChapter")
      .select("id, id_komik, chapter_number, release_date, thumbnail_image_url")
      .in("id_komik", comicIds)
      .order("release_date", { ascending: false })
      .limit(limit * 2); // Fetch enough chapters to cover 2 per comic

    if (chaptersError) {
      console.error("Error fetching chapters:", chaptersError);
      return NextResponse.json({ error: chaptersError.message }, { status: 500 });
    }

    // Group chapters by comic ID
    const chaptersByComicId: Record<string, any[]> = {};
    
    // Pastikan chaptersData adalah array dan bukan error
    if (chaptersData && Array.isArray(chaptersData)) {
      chaptersData.forEach((chapter: any) => {
        // Pastikan chapter memiliki id_komik
        if (chapter && chapter.id_komik) {
          const comicId = chapter.id_komik;
          if (!chaptersByComicId[comicId]) {
            chaptersByComicId[comicId] = [];
          }
          // Only keep the 2 latest chapters per comic
          if (chaptersByComicId[comicId].length < 2) {
            chaptersByComicId[comicId].push(chapter);
          }
        }
      });
    }

    // Transform data to include genres as an array and latest chapters
    const transformedData = comicsData && Array.isArray(comicsData) ? comicsData.map((comic: any) => {
      // Extract genres from nested structure
      const genres = comic.trGenre && Array.isArray(comic.trGenre) 
        ? comic.trGenre.map((genre: any) => genre.mGenre).filter(Boolean)
        : [];
      
      // Get latest chapters for this comic
      const latestChapters = comic.id && chaptersByComicId[comic.id] ? chaptersByComicId[comic.id] : [];

      // Return comic with genres array and latest chapters
      return {
        ...comic,
        // Format chapter count
        chapter_count: comic.mChapter && comic.mChapter[0] ? comic.mChapter[0].count || 0 : 0,
        // Replace trGenre with formatted genres
        genres,
        // Add latest chapters
        latest_chapters: latestChapters,
        // Remove unnecessary fields
        trGenre: undefined,
        mChapter: undefined,
      };
    }) : [];

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    // Sort by latest chapter release date if no explicit sort parameter was provided
    if (!sort) {
      transformedData.sort((a, b) => {
        // Get the latest chapter for each comic
        const latestChapterA = a.latest_chapters && a.latest_chapters.length > 0 ? 
          a.latest_chapters[0] : null;
        const latestChapterB = b.latest_chapters && b.latest_chapters.length > 0 ? 
          b.latest_chapters[0] : null;
        
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
      data: transformedData,
      meta: {
        currentPage: page,
        totalPages: Math.ceil((count || 0) / limit),
        totalItems: count || 0,
        itemsPerPage: limit,
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
