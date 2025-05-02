import { createBrowserClient } from "@supabase/ssr";
import { createClient } from "@supabase/supabase-js";
import { Database } from "@/lib/supabase/database.types";

// Default values
const defaultSupabaseUrl = "https://owiowqcpkksbuuoyhplm.supabase.co";
const defaultSupabaseAnonKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aW93cWNwa2tzYnV1b3locGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzc5MTEsImV4cCI6MjA2MTY1MzkxMX0.T230qvftj_LATF2tg1zKdHpMRjr0tqyIsP-zcMxVlco";

// For client components
export const createBrowserSupabaseClient = () => {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL || defaultSupabaseUrl,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || defaultSupabaseAnonKey
  );
};

// For server-side in Pages Router
export const createServerSupabaseClient = (context: any) => {
  // You'll need to use a different approach for the Pages Router
  // This function should be called with the API or getServerSideProps context
  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL || defaultSupabaseUrl,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || defaultSupabaseAnonKey,
    {
      global: {
        headers: {
          cookie: context?.req?.headers?.cookie || "",
        },
      },
    }
  );
};

// Get URL and keys with fallbacks
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || defaultSupabaseUrl;
const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || defaultSupabaseAnonKey;
// For service key, we'll provide a fallback but you should set this in your environment
const supabaseServiceKey =
  process.env.SUPABASE_SERVICE_KEY || defaultSupabaseAnonKey;

// Client regular dengan anon key
export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey);

// Client admin dengan service_role key untuk admin operations
export const supabaseAdmin = createClient<Database>(
  supabaseUrl,
  supabaseServiceKey
);
