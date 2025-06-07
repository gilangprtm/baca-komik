import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";

export async function GET(request: NextRequest) {
  try {
    // Get query parameters
    const { searchParams } = new URL(request.url);
    const typeParam = searchParams.get("type") || "all_time";
    const limit = parseInt(searchParams.get("limit") || "20");

    // Validate type parameter
    const validTypes = ["harian", "mingguan", "bulanan", "all_time"] as const;
    type ValidType = (typeof validTypes)[number];

    if (!validTypes.includes(typeParam as ValidType)) {
      return NextResponse.json(
        { error: `Invalid type. Must be one of: ${validTypes.join(", ")}` },
        { status: 400 }
      );
    }

    // Type assertion after validation
    const type = typeParam as ValidType;

    // Fetch popular comics from mPopular table with JOIN to mKomik
    const { data: popularComics, error: popularError } = await supabaseAdmin
      .from("mPopular")
      .select(
        `
        id_komik,
        type,
        mKomik!mPopular_id_komik_fkey (
          id,
          title,
          alternative_title,
          cover_image_url,
          country_id,
          view_count,
          vote_count,
          bookmark_count,
          status,
          created_date
        )
      `
      )
      .eq("type", type)
      .limit(limit);

    if (popularError) {
      console.error("Error fetching popular comics:", popularError);
      return NextResponse.json(
        { error: popularError.message },
        { status: 500 }
      );
    }

    // Transform the data to flatten the structure
    const transformedPopularComics =
      popularComics?.map((item) => ({
        id: item.mKomik.id,
        title: item.mKomik.title,
        alternative_title: item.mKomik.alternative_title,
        cover_image_url: item.mKomik.cover_image_url,
        country_id: item.mKomik.country_id,
        view_count: item.mKomik.view_count,
        vote_count: item.mKomik.vote_count,
        bookmark_count: item.mKomik.bookmark_count,
        status: item.mKomik.status,
        created_date: item.mKomik.created_date,

        type: item.type,
      })) || [];

    return NextResponse.json({
      data: transformedPopularComics,
      meta: {
        type,
        limit,
        total: transformedPopularComics.length,
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
