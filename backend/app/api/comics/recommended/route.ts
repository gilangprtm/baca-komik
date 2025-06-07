import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";

export async function GET(request: NextRequest) {
  try {
    // Get query parameters
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get("limit") || "20");

    // Fetch recommended comics from mRecomed table with JOIN to mKomik
    const { data: recommendedComics, error: recommendedError } =
      await supabaseAdmin
        .from("mRecomed")
        .select(
          `
        id_komik,
        mKomik!mRecomed_id_komik_fkey (
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
        .limit(limit);

    if (recommendedError) {
      console.error("Error fetching recommended comics:", recommendedError);
      return NextResponse.json(
        { error: recommendedError.message },
        { status: 500 }
      );
    }

    // Transform the data to flatten the structure
    const transformedRecommendedComics =
      recommendedComics?.map((item) => ({
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
      })) || [];

    return NextResponse.json({
      data: transformedRecommendedComics,
      meta: {
        limit,
        total: transformedRecommendedComics.length,
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
