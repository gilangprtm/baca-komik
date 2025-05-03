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
    const search = searchParams.get("search") || "";
    const genre = searchParams.get("genre") || "";
    const format = searchParams.get("format") || "";
    const country = searchParams.get("country") || "";

    // Calculate offset
    const offset = (page - 1) * limit;

    // Fetch popular comics (by view count)
    const { data: popularComics, error: popularError } = await supabaseAdmin
      .from("mKomik")
      .select("id, title, cover_image_url, country_id, view_count")
      .order("view_count", { ascending: false })
      .limit(10);

    if (popularError) {
      console.error("Error fetching popular comics:", popularError);
      return NextResponse.json({ error: popularError.message }, { status: 500 });
    }

    // Fetch recommended comics (by rank)
    const { data: recommendedComics, error: recommendedError } = await supabaseAdmin
      .from("mKomik")
      .select("id, title, cover_image_url, country_id")
      .order("rank", { ascending: false })
      .limit(10);

    if (recommendedError) {
      console.error("Error fetching recommended comics:", recommendedError);
      return NextResponse.json({ error: recommendedError.message }, { status: 500 });
    }

    // Build query for search results
    let searchQuery = supabaseAdmin.from("mKomik").select(
      `
        *,
        mChapter!mChapter_id_komik_fkey (count),
        trGenre!trGenre_id_komik_fkey (id_genre, mGenre!inner (id, name)),
        trFormat!trFormat_id_komik_fkey (id_format, mFormat!inner (id, name))
      `,
      { count: "exact" }
    );

    // Apply search filter
    if (search) {
      searchQuery = searchQuery.or(
        `title.ilike.%${search}%,alternative_title.ilike.%${search}%`
      );
    }

    // Apply country filter
    if (country && ["KR", "JPN", "CN"].includes(country)) {
      searchQuery = searchQuery.eq("country_id", country as CountryType);
    }

    // Apply genre filter
    if (genre) {
      searchQuery = searchQuery.filter("trGenre.mGenre.id", "eq", genre);
    }

    // Apply format filter
    if (format) {
      searchQuery = searchQuery.filter("trFormat.mFormat.id", "eq", format);
    }

    // Apply pagination
    searchQuery = searchQuery.range(offset, offset + limit - 1);

    // Execute search query
    const { data: searchResults, error: searchError, count } = await searchQuery;

    if (searchError) {
      console.error("Error fetching search results:", searchError);
      return NextResponse.json({ error: searchError.message }, { status: 500 });
    }

    // Transform search results to include genres and formats as arrays
    const transformedSearchResults = searchResults?.map((comic) => {
      // Extract genres from nested structure
      const genres = comic.trGenre?.map((genre: any) => genre.mGenre) || [];
      
      // Extract formats from nested structure
      const formats = comic.trFormat?.map((format: any) => format.mFormat) || [];

      // Return comic with genres and formats arrays
      return {
        ...comic,
        // Format chapter count
        chapter_count: comic.mChapter?.[0]?.count || 0,
        // Replace trGenre with formatted genres
        genres,
        // Replace trFormat with formatted formats
        formats,
        // Remove unnecessary fields
        trGenre: undefined,
        trFormat: undefined,
        mChapter: undefined,
      };
    });

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    return NextResponse.json({
      popular: popularComics,
      recommended: recommendedComics,
      search_results: {
        data: transformedSearchResults,
        meta: {
          page,
          limit,
          total: count,
          total_pages: totalPages,
          has_more: page < totalPages,
        },
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
