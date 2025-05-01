import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";
import { createClient } from "@/lib/supabase/middleware";

// GET /api/bookmarks - Get user bookmarks
export async function GET(request: NextRequest) {
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

    // Get query parameters
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get("page") || "1");
    const limit = parseInt(searchParams.get("limit") || "10");

    // Calculate offset
    const offset = (page - 1) * limit;

    // Get bookmarks with comic information
    const { data, error, count } = await supabase
      .from("trUserBookmark")
      .select(
        `
        *,
        mKomik!inner (
          id,
          title,
          cover_image_url,
          alternative_title,
          description,
          rating,
          status,
          country_id
        )
      `,
        { count: "exact" }
      )
      .eq("id_user", user.id)
      .order("created_at", { ascending: false })
      .range(offset, offset + limit - 1);

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

// POST /api/bookmarks - Add bookmark
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
    const { id_komik } = body;

    if (!id_komik) {
      return NextResponse.json(
        { error: "Comic ID is required" },
        { status: 400 }
      );
    }

    // Check if comic exists
    const { data: comic, error: comicError } = await supabase
      .from("mKomik")
      .select("id")
      .eq("id", id_komik)
      .single();

    if (comicError || !comic) {
      return NextResponse.json({ error: "Comic not found" }, { status: 404 });
    }

    // Check if bookmark already exists
    const { data: existingBookmark, error: existingError } = await supabase
      .from("trUserBookmark")
      .select("id_user, id_komik")
      .eq("id_user", user.id)
      .eq("id_komik", id_komik)
      .maybeSingle();

    if (existingBookmark) {
      return NextResponse.json(
        {
          error: "Bookmark already exists",
          id_komik: existingBookmark.id_komik,
        },
        { status: 409 }
      );
    }

    // Create bookmark
    const { data, error } = await supabase
      .from("trUserBookmark")
      .insert({
        id_user: user.id,
        id_komik,
      })
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Trigger function to update bookmark count
    await supabaseAdmin.rpc("update_comic_bookmark_count", {
      comic_id: id_komik,
    });

    return NextResponse.json(data, { status: 201 });
  } catch (error) {
    console.error("Unexpected error:", error);
    return NextResponse.json(
      { error: "An unexpected error occurred" },
      { status: 500 }
    );
  }
}
