import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";

// POST /api/comments - Add comment
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
    const { content, id_komik, id_chapter, parent_id } = body;

    // Validate required fields
    if (!content) {
      return NextResponse.json(
        { error: "Comment content is required" },
        { status: 400 }
      );
    }

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

    // Check if parent comment exists if provided
    if (parent_id) {
      const { data: parentComment, error: parentError } = await supabase
        .from("trComments")
        .select("id")
        .eq("id", parent_id)
        .single();

      if (parentError || !parentComment) {
        return NextResponse.json(
          { error: "Parent comment not found" },
          { status: 404 }
        );
      }
    }

    // Create comment
    const { data, error } = await supabase
      .from("trComments")
      .insert({
        content,
        id_komik,
        id_chapter,
        id_user: user.id,
        parent_id,
        created_date: new Date().toISOString(),
      })
      .select(
        `
        *,
        mUser!trComments_id_user_fkey (
          id,
          name,
          avatar_url
        )
      `
      )
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json(data, { status: 201 });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
