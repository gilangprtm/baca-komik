import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";
import { supabaseAdmin } from "@/lib/supabase/client";

// GET /api/chapters/:id/pages - Get pages for a chapter
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const supabase = createClient(request);

    // Validate ID
    if (!id || typeof id !== "string") {
      return NextResponse.json(
        { error: "Invalid chapter ID" },
        { status: 400 }
      );
    }

    // First, verify that the chapter exists
    const { data: chapter, error: chapterError } = await supabaseAdmin
      .from("mChapter")
      .select("id, chapter_number, id_komik")
      .eq("id", id)
      .single();

    if (chapterError) {
      if (chapterError.code === "PGRST116") {
        return NextResponse.json(
          { error: "Chapter not found" },
          { status: 404 }
        );
      }
      return NextResponse.json(
        { error: chapterError.message },
        { status: 500 }
      );
    }

    // Fetch pages for the chapter, sorted by page number
    const { data, error } = await supabaseAdmin
      .from("trChapter")
      .select("*")
      .eq("id_chapter", id)
      .order("page_number", { ascending: true });

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Fetch comic information
    const { data: comic, error: comicError } = await supabaseAdmin
      .from("mKomik")
      .select("id, title")
      .eq("id", chapter.id_komik)
      .single();

    if (comicError) {
      return NextResponse.json({ error: comicError.message }, { status: 500 });
    }

    return NextResponse.json({
      chapter: {
        id: chapter.id,
        chapter_number: chapter.chapter_number,
        comic: comic,
      },
      pages: data,
      count: data.length,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
