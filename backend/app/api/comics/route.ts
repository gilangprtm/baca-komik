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
    const sort = searchParams.get("sort") || "rank";
    const order = searchParams.get("order") || "desc";
    const search = searchParams.get("search") || "";
    const genre = searchParams.get("genre") || "";
    const country = searchParams.get("country") || "";

    // Calculate offset
    const offset = (page - 1) * limit;

    // Build query
    let query = supabaseAdmin.from("mKomik").select(
      `
        *,
        mChapter!mChapter_id_komik_fkey (count),
        trGenre!trGenre_id_komik_fkey (id_genre, mGenre!inner (id, name))
      `,
      { count: "exact" }
    );

    // Apply search filter
    if (search) {
      query = query.or(
        `title.ilike.%${search}%,alternative_title.ilike.%${search}%`
      );
    }

    // Apply country filter
    if (country && ["KR", "JPN", "CN"].includes(country)) {
      query = query.eq("country_id", country as CountryType);
    }

    // Apply genre filter
    if (genre) {
      query = query.filter("trGenre.mGenre.id", "eq", genre);
    }

    // Apply sorting
    if (sort && order) {
      query = query.order(sort, { ascending: order === "asc" });
    }

    // Apply pagination
    query = query.range(offset, offset + limit - 1);

    // Execute query
    const { data, error, count } = await query;

    if (error) {
      console.error("Error fetching comics:", error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Transform data to include genres as an array
    const transformedData = data?.map((comic) => {
      // Extract genres from nested structure
      const genres = comic.trGenre?.map((genre: any) => genre.mGenre) || [];

      // Return comic with genres array
      return {
        ...comic,
        // Format chapter count
        chapter_count: comic.mChapter?.[0]?.count || 0,
        // Replace trGenre with formatted genres
        genres,
        trGenre: undefined,
        mChapter: undefined,
      };
    });

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
