import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { createClient } from "@/lib/supabase/middleware";

// DELETE /api/bookmarks/:id - Remove bookmark
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params; // id_komik
    const supabase = createClient(request);

    // Check if user is authenticated
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Check if bookmark exists and belongs to user
    const { data: bookmark, error: bookmarkError } = await supabase
      .from("trUserBookmark")
      .select("id_komik, id_user")
      .eq("id_komik", id)
      .eq("id_user", user.id)
      .single();

    if (bookmarkError || !bookmark) {
      return NextResponse.json(
        { error: "Bookmark not found or does not belong to user" },
        { status: 404 }
      );
    }

    // Delete bookmark
    const { error } = await supabase
      .from("trUserBookmark")
      .delete()
      .eq("id_komik", id)
      .eq("id_user", user.id);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Trigger function to update bookmark count
    await supabaseAdmin.rpc("update_comic_bookmark_count", { comic_id: id });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
