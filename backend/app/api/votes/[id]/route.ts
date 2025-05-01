import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { createClient } from "@/lib/supabase/middleware";

interface RouteParams {
  params: {
    id: string;
  };
}

// DELETE /api/votes/:id - Remove vote
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { id } = params;
    const { searchParams } = new URL(request.url);
    const type = searchParams.get("type") || "comic";

    if (type !== "comic" && type !== "chapter") {
      return NextResponse.json(
        { error: "Invalid type. Must be 'comic' or 'chapter'" },
        { status: 400 }
      );
    }

    const supabase = createClient(request);

    // Check if user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Delete vote based on type
    if (type === "comic") {
      // Check if vote exists and belongs to user
      const { data: vote, error: voteError } = await supabase
        .from("mKomikVote")
        .select("id_komik, id_user")
        .eq("id_komik", id)
        .eq("id_user", user.id)
        .single();

      if (voteError || !vote) {
        return NextResponse.json(
          { error: "Vote not found or does not belong to user" },
          { status: 404 }
        );
      }

      // Delete vote
      const { error } = await supabase
        .from("mKomikVote")
        .delete()
        .eq("id_komik", id)
        .eq("id_user", user.id);

      if (error) {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }

      // Trigger function to update vote count and rank
      await supabaseAdmin.rpc("update_comic_vote_count", { comic_id: id });
      await supabaseAdmin.rpc("update_comic_rank", { comic_id: id });

      return NextResponse.json({ success: true }, { status: 200 });
    } else {
      // Check if vote exists and belongs to user
      const { data: vote, error: voteError } = await supabase
        .from("trChapterVote")
        .select("id_chapter, id_user")
        .eq("id_chapter", id)
        .eq("id_user", user.id)
        .single();

      if (voteError || !vote) {
        return NextResponse.json(
          { error: "Vote not found or does not belong to user" },
          { status: 404 }
        );
      }

      // Delete vote
      const { error } = await supabase
        .from("trChapterVote")
        .delete()
        .eq("id_chapter", id)
        .eq("id_user", user.id);

      if (error) {
        return NextResponse.json({ error: error.message }, { status: 500 });
      }

      // Trigger function to update vote count
      await supabaseAdmin.rpc("update_chapter_vote_count", { chapter_id: id });

      return NextResponse.json({ success: true }, { status: 200 });
    }
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
