import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";

// GET /api/comics/:id/chapters - Get chapters for a comic
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "20");
    const sort = searchParams.get("sort") || "chapter_number";
    const order = searchParams.get("order") || "desc";

    // Calculate offset for pagination
    const offset = (page - 1) * limit;

    // Validate comic ID
    if (!id || typeof id !== "string") {
      return NextResponse.json({ error: "Invalid comic ID" }, { status: 400 });
    }

    // First check if comic exists
    const { data: comic, error: comicError } = await supabaseAdmin
      .from("mKomik")
      .select("id, title")
      .eq("id", id)
      .single();

    if (comicError) {
      if (comicError.code === "PGRST116") {
        return NextResponse.json({ error: "Comic not found" }, { status: 404 });
      }
      return NextResponse.json({ error: comicError.message }, { status: 500 });
    }

    // Fetch chapters for the comic with pagination
    const { data, error, count } = await supabaseAdmin
      .from("mChapter")
      .select("*", { count: "exact" })
      .eq("id_komik", id)
      .order(sort, { ascending: order === "asc" })
      .range(offset, offset + limit - 1);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Calculate total pages
    const totalPages = count ? Math.ceil(count / limit) : 0;

    return NextResponse.json({
      comic,
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
