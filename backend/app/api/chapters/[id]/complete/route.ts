import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";
import { supabaseAdmin } from "@/lib/supabase/client";

// GET /api/chapters/:id/complete - Get complete chapter details with pages and navigation
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

    // Check if user is authenticated
    const {
      data: { user },
    } = await supabase.auth.getUser();

    // Fetch chapter with comic information
    const { data: chapterData, error: chapterError } = await supabaseAdmin
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

    if (chapterError) {
      if (chapterError.code === "PGRST116") {
        return NextResponse.json(
          { error: "Chapter not found" },
          { status: 404 }
        );
      }
      return NextResponse.json({ error: chapterError.message }, { status: 500 });
    }

    if (!chapterData) {
      return NextResponse.json({ error: "Chapter not found" }, { status: 404 });
    }

    // Fetch pages for the chapter, sorted by page number
    const { data: pagesData, error: pagesError } = await supabaseAdmin
      .from("trChapter")
      .select("id_chapter, page_number, page_url")
      .eq("id_chapter", id)
      .order("page_number", { ascending: true });

    if (pagesError) {
      return NextResponse.json({ error: pagesError.message }, { status: 500 });
    }

    // Fetch next and previous chapters for navigation
    let prevChapter = null;
    let nextChapter = null;

    try {
      const prevResult = await supabaseAdmin
        .from("mChapter")
        .select("id, chapter_number")
        .eq("id_komik", chapterData.id_komik)
        .lt("chapter_number", chapterData.chapter_number)
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
        .eq("id_komik", chapterData.id_komik)
        .gt("chapter_number", chapterData.chapter_number)
        .order("chapter_number", { ascending: true })
        .limit(1)
        .single();

      nextChapter = nextResult.data;
    } catch (e) {
      // No next chapter found
    }

    // Initialize user data
    let userData = {
      is_voted: false,
      is_read: false
    };

    // If user is authenticated, fetch user-specific data
    if (user) {
      // Check if chapter is voted
      const { data: voteData } = await supabase
        .from("trChapterVote")
        .select("id_chapter")
        .eq("id_user", user.id)
        .eq("id_chapter", id)
        .maybeSingle();

      // Check if chapter is marked as read
      const { data: readData } = await supabase
        .from("trUserHistory")
        .select("is_read")
        .eq("id_user", user.id)
        .eq("id_chapter", id)
        .maybeSingle();

      userData = {
        is_voted: !!voteData,
        is_read: readData?.is_read || false
      };

      // Update reading history if user is authenticated
      if (user) {
        // Check if reading history exists
        const { data: existingHistory } = await supabase
          .from("trUserHistory")
          .select("id_user, id_komik, id_chapter")
          .eq("id_user", user.id)
          .eq("id_chapter", id)
          .maybeSingle();

        if (!existingHistory) {
          // Create new reading history
          await supabase.from("trUserHistory").insert({
            id_user: user.id,
            id_komik: chapterData.id_komik,
            id_chapter: id,
            is_read: false // Initially set to false, will be updated when user finishes reading
          });
        }
      }
    }

    // Increment view count
    await supabaseAdmin.rpc("increment_chapter_view_count", { chapter_id: id });

    // Format response
    const formattedChapter = {
      ...chapterData,
      comic: chapterData.mKomik,
      mKomik: undefined,
    };

    return NextResponse.json({
      chapter: formattedChapter,
      pages: pagesData,
      navigation: {
        prev_chapter: prevChapter,
        next_chapter: nextChapter
      },
      user_data: userData
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
