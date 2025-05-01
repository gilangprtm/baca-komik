import { createRouteHandlerClient } from "@supabase/auth-helpers-nextjs";
import { cookies } from "next/headers";
import { NextRequest } from "next/server";
import { Database } from "./database.types";

export function createClient(request: NextRequest) {
  return createRouteHandlerClient<Database>({
    cookies,
  });
}
