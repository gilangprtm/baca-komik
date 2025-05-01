import { createBrowserClient, createServerClient } from "@supabase/ssr";
import { createClient } from "@supabase/supabase-js";
import { Database } from "@/lib/supabase/database.types";
import { cookies } from "next/headers";

// For client components
export const createBrowserSupabaseClient = () => {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL ||
      "https://owiowqcpkksbuuoyhplm.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aW93cWNwa2tzYnV1b3locGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzc5MTEsImV4cCI6MjA2MTY1MzkxMX0.T230qvftj_LATF2tg1zKdHpMRjr0tqyIsP-zcMxVlco"
  );
};

// For server components
export const createServerSupabaseClient = () => {
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL ||
      "https://owiowqcpkksbuuoyhplm.supabase.co",
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ||
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aW93cWNwa2tzYnV1b3locGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzc5MTEsImV4cCI6MjA2MTY1MzkxMX0.T230qvftj_LATF2tg1zKdHpMRjr0tqyIsP-zcMxVlco",
    {
      cookies: {
        get: async (name) => {
          return (await cookies()).get(name)?.value;
        },
        set: () => {},
        remove: () => {},
      },
    }
  );
};

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;

// Client regular dengan anon key
export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);

// Client admin dengan service_role key untuk admin operations
export const supabaseAdmin = createClient<Database>(
  supabaseUrl,
  supabaseServiceKey
);
