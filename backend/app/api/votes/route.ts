import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { createClient } from "@/lib/supabase/middleware";

// POST /api/votes - Add vote
export async function POST(request: NextRequest) {
  try {
    const supabase = createClient(request);

    // Check if user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Get request body
    const body = await request.json();
    const { id_komik, id_chapter } = body;

    if (!id_komik && !id_chapter) {
      return NextResponse.json(
        { error: "Comic ID or Chapter ID is required" },
        { status: 400 }
      );
    }

    if (id_komik && id_chapter) {
      return NextResponse.json(
        { error: "Provide either Comic ID or Chapter ID, not both" },
        { status: 400 }
      );
    }

    // Process comic vote
    if (id_komik) {
      // Check if comic exists
      const { data: comic, error: comicError } = await supabase
        .from("mKomik")
        .select("id")
        .eq("id", id_komik)
        .single();

      if (comicError || !comic) {
        return NextResponse.json({ error: "Comic not found" }, { status: 404 });
      }

      // Check if vote already exists
      const { data: existingVote, error: existingError } = await supabase
        .from("mKomikVote")
        .select("id_user, id_komik")
        .eq("id_user", user.id)
        .eq("id_komik", id_komik)
        .maybeSingle();

      if (existingVote) {
        return NextResponse.json(
          { error: "Vote already exists", id_komik: existingVote.id_komik },
          { status: 409 }
        );
      }

      // Create vote
      const { data, error } = await supabase
        .from("mKomikVote")
        .insert({
          id_user: user.id,
          id_komik,
        })
        .select()
        .single();

      if (error) {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }

      // Trigger function to update vote count
      await supabaseAdmin.rpc("update_comic_vote_count", {
        comic_id: id_komik,
      });
      await supabaseAdmin.rpc("update_comic_rank", { comic_id: id_komik });

      return NextResponse.json(data, { status: 201 });
    }

    // Process chapter vote
    if (id_chapter) {
      // Check if chapter exists
      const { data: chapter, error: chapterError } = await supabase
        .from("mChapter")
        .select("id")
        .eq("id", id_chapter)
        .single();

      if (chapterError || !chapter) {
        return NextResponse.json(
          { error: "Chapter not found" },
          { status: 404 }
        );
      }

      // Check if vote already exists
      const { data: existingVote, error: existingError } = await supabase
        .from("trChapterVote")
        .select("id_user, id_chapter")
        .eq("id_user", user.id)
        .eq("id_chapter", id_chapter)
        .maybeSingle();

      if (existingVote) {
        return NextResponse.json(
          { error: "Vote already exists", id_chapter: existingVote.id_chapter },
          { status: 409 }
        );
      }

      // Create vote
      const { data, error } = await supabase
        .from("trChapterVote")
        .insert({
          id_user: user.id,
          id_chapter,
        })
        .select()
        .single();

      if (error) {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }

      // Trigger function to update vote count
      await supabaseAdmin.rpc("update_chapter_vote_count", {
        chapter_id: id_chapter,
      });

      return NextResponse.json(data, { status: 201 });
    }

    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
