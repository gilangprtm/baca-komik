import { createMiddlewareClient } from "@supabase/auth-helpers-nextjs";
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { Database } from "@/lib/supabase/database.types";

// Rute yang memerlukan autentikasi
const PROTECTED_ROUTES = [
  "/api/bookmarks",
  "/api/votes",
  "/api/comments",
  "/admin",
];

// Helper untuk menentukan apakah rute perlu diautentikasi
const isProtectedRoute = (path: string) => {
  return PROTECTED_ROUTES.some((route) => {
    // Cek rute langsung atau sub-rute (contoh: /api/bookmarks/123)
    return path === route || path.startsWith(`${route}/`);
  });
};

export async function middleware(request: NextRequest) {
  const response = NextResponse.next();
  const supabase = createMiddlewareClient<Database>({
    req: request,
    res: response,
  });

  // Refresh session jika ada
  const {
    data: { session },
    error,
  } = await supabase.auth.getSession();

  const requestPath = request.nextUrl.pathname;

  // Jika ini adalah rute terproteksi dan tidak ada sesi, kembalikan 401
  if (isProtectedRoute(requestPath) && !session) {
    if (requestPath.startsWith("/api/")) {
      // Return API error untuk endpoint API
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    } else {
      // Redirect ke login untuk halaman admin
      const redirectUrl = new URL("/auth/login", request.url);
      redirectUrl.searchParams.set("redirectedFrom", requestPath);
      return NextResponse.redirect(redirectUrl);
    }
  }

  return response;
}

// Configure matcher untuk middleware
export const config = {
  matcher: [
    "/api/bookmarks/:path*",
    "/api/votes/:path*",
    "/api/comments/:path*",
    "/admin/:path*",
  ],
};
