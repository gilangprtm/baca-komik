import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";
import { supabaseAdmin } from "@/lib/supabase/client";

// Helper function to get chapter count for a comic
async function getChapterCount(comicId: string): Promise<number> {
  const { count, error } = await supabaseAdmin
    .from("mChapter")
    .select("*", { count: "exact", head: true })
    .eq("id_komik", comicId);
    
  if (error) {
    console.error("Error getting chapter count:", error);
    return 0;
  }
  
  return count || 0;
}

// GET /api/comics/:id - Get comic details
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

    // Fetch comic with related data - excluding chapters for optimization
    const { data, error } = await supabaseAdmin
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

    // Format response - chapters will be fetched separately via /comics/:id/chapters
    const formattedComic = {
      ...data,
      genres: data.trGenre.map((genre: any) => genre.mGenre),
      authors: data.trAuthor.map((author: any) => author.mAuthor),
      artists: data.trArtist.map((artist: any) => artist.mArtist),
      formats: data.trFormat.map((format: any) => format.mFormat),
      // Add chapter_count for UI display without loading all chapters
      chapter_count: await getChapterCount(id),
      // Remove raw relationship data
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
