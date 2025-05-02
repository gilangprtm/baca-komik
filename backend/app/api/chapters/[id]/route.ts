import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";
import { supabaseAdmin } from "@/lib/supabase/client";

// GET /api/chapters/:id - Get chapter details
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

    // Fetch chapter with comic information
    const { data, error } = await supabaseAdmin
      .from("mChapter")
      .select(
        `
        *,
        mKomik!mChapter_id_komik_fkey (
          id, 
          title, 
          alternative_title,
          cover_image_url
        )
      `
      )
      .eq("id", id)
      .single();

    if (error) {
      if (error.code === "PGRST116") {
        return NextResponse.json(
          { error: "Chapter not found" },
          { status: 404 }
        );
      }
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    if (!data) {
      return NextResponse.json({ error: "Chapter not found" }, { status: 404 });
    }

    // Increment view count
    await supabaseAdmin.rpc("increment_chapter_view_count", { chapter_id: id });

    // Fetch next and previous chapters for navigation
    let prevChapter = null;
    let nextChapter = null;

    try {
      const prevResult = await supabaseAdmin
        .from("mChapter")
        .select("id, chapter_number")
        .eq("id_komik", data.id_komik)
        .lt("chapter_number", data.chapter_number)
        .order("chapter_number", { ascending: false })
        .limit(1)
        .single();

      prevChapter = prevResult.data;
    } catch (e) {
      // No previous chapter found
    }

    try {
      const nextResult = await supabaseAdmin
        .from("mChapter")
        .select("id, chapter_number")
        .eq("id_komik", data.id_komik)
        .gt("chapter_number", data.chapter_number)
        .order("chapter_number", { ascending: true })
        .limit(1)
        .single();

      nextChapter = nextResult.data;
    } catch (e) {
      // No next chapter found
    }

    // Format response
    const formattedChapter = {
      ...data,
      comic: data.mKomik,
      next_chapter: nextChapter,
      prev_chapter: prevChapter,
      mKomik: undefined,
    };

    return NextResponse.json(formattedChapter);
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
