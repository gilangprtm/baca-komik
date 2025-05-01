import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";

interface RouteParams {
  params: {
    id: string;
  };
}

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = params;

    // Validate ID
    if (!id || typeof id !== "string") {
      return NextResponse.json({ error: "Invalid comic ID" }, { status: 400 });
    }

    // Fetch comic with related data
    const { data, error } = await supabaseAdmin
      .from("mKomik")
      .select(
        `
        *,
        mChapter!mChapter_id_komik_fkey (
          id, 
          chapter_number, 
          release_date, 
          rating, 
          view_count, 
          vote_count, 
          thumbnail_image_url
        ),
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

    if (error) {
      if (error.code === "PGRST116") {
        return NextResponse.json({ error: "Comic not found" }, { status: 404 });
      }
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    if (!data) {
      return NextResponse.json({ error: "Comic not found" }, { status: 404 });
    }

    // Increment view count
    await supabaseAdmin.rpc("increment_comic_view_count", { comic_id: id });

    // Format response
    const formattedComic = {
      ...data,
      chapters: data.mChapter,
      genres: data.trGenre.map((genre: any) => genre.mGenre),
      authors: data.trAuthor.map((author: any) => author.mAuthor),
      artists: data.trArtist.map((artist: any) => artist.mArtist),
      formats: data.trFormat.map((format: any) => format.mFormat),
      // Remove raw relationship data
      mChapter: undefined,
      trGenre: undefined,
      trAuthor: undefined,
      trArtist: undefined,
      trFormat: undefined,
    };

    return NextResponse.json(formattedComic);
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
