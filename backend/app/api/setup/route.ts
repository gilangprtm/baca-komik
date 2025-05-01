import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase/client";

export async function GET() {
  try {
    // Check if user already exists
    const { data: existingUser, error: checkError } = await supabaseAdmin
      .from("mUser")
      .select("id")
      .eq("name", "master")
      .maybeSingle();

    if (checkError) {
      console.error("Error checking for existing user:", checkError);
    }

    if (existingUser) {
      return NextResponse.json(
        { message: "Admin user already exists" },
        { status: 200 }
      );
    }

    // Create admin user in Supabase Auth
    const { data: authUser, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email: "master@bacakomik.com",
        password: "Master1234",
        email_confirm: true,
        user_metadata: { role: "admin" },
      });

    if (authError) {
      console.error("Auth error full details:", authError);
      return NextResponse.json(
        { error: `Auth error: ${authError.message}` },
        { status: 500 }
      );
    }

    // Add user to mUser table
    const { error: userError } = await supabaseAdmin.from("mUser").insert({
      id: authUser.user.id,
      name: "master",
      avatar_url: null,
      created_date: new Date().toISOString(),
    });

    if (userError) {
      console.error("Database error full details:", userError);
      return NextResponse.json(
        { error: `Database error: ${userError.message}` },
        { status: 500 }
      );
    }

    return NextResponse.json(
      {
        message: "Admin user created successfully",
        user: {
          email: "master@bacakomik.com",
          password: "Master1234",
        },
      },
      { status: 201 }
    );
  } catch (error: any) {
    console.error("Error creating admin user (full details):", error);
    return NextResponse.json(
      { error: error.message || "Error creating admin user" },
      { status: 500 }
    );
  }
}
