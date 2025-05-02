import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/middleware";

type RouteParams = { params: { id: string } };

// GET /api/comments/:id - Get comments for a comic or chapter
export async function GET(request: NextRequest, context: RouteParams) {
  try {
    const { id } = context.params;
    const { searchParams } = new URL(request.url);
    const type = searchParams.get("type") || "comic";
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "10");
    const parent_only = searchParams.get("parent_only") === "true";

    if (type !== "comic" && type !== "chapter") {
      return NextResponse.json(
        { error: "Invalid type. Must be 'comic' or 'chapter'" },
        { status: 400 }
      );
    }

    // Calculate offset
    const offset = (page - 1) * limit;

    const supabase = createClient(request);

    // Build query based on type
    let query = supabase.from("trComments").select(
      `
        *,
        mUser!trComments_id_user_fkey (
          id,
          name,
          avatar_url
        ),
        replies:trComments!trComments_parent_id_fkey (
          id,
          content,
          created_date,
          mUser!trComments_id_user_fkey (
            id,
            name,
            avatar_url
          )
        )
      `,
      { count: "exact" }
    );

    if (type === "comic") {
      query = query.eq("id_komik", id);
    } else {
      query = query.eq("id_chapter", id);
    }

    // Only get parent comments if requested
    if (parent_only) {
      query = query.is("parent_id", null);
    }

    // Apply pagination and sorting
    query = query
      .order("created_date", { ascending: false })
      .range(offset, offset + limit - 1);

    // Execute query
    const { data, error, count } = await query;

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    return NextResponse.json({
      data,
      meta: {
        page,
        limit,
        total: count,
        total_pages: totalPages,
        has_more: page < totalPages,
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
