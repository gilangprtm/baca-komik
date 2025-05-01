"use client";

import { useState, useEffect, ReactNode } from "react";
import { usePathname, useRouter } from "next/navigation";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import { AdminLayout } from "@/components/admin-layout";

interface Route {
  path: string;
  component: ReactNode;
}

interface SPARouterProps {
  routes: Route[];
}

export function SPARouter({ routes }: SPARouterProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [currentComponent, setCurrentComponent] = useState<ReactNode | null>(
    null
  );
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const supabase = createClientComponentClient<Database>();

  // Auth check
  useEffect(() => {
    async function getUser() {
      setLoading(true);

      try {
        const {
          data: { session },
          error,
        } = await supabase.auth.getSession();

        if (error || !session) {
          router.push("/auth/login");
          return;
        }

        setUser(session.user);
      } catch (error) {
        console.error("Error loading user:", error);
      } finally {
        setLoading(false);
      }
    }

    getUser();
  }, [router, supabase]);

  // Route matching
  useEffect(() => {
    // Find the matching route based on the current pathname
    const matchRoute = () => {
      // First try exact match
      let match = routes.find((route) => route.path === pathname);

      if (match) {
        setCurrentComponent(match.component);
        return;
      }

      // Try pattern matching for dynamic routes
      for (const route of routes) {
        // Handle routes with parameters like /admin/comics/:id
        if (route.path.includes(":")) {
          const routeParts = route.path.split("/");
          const pathnameParts = pathname.split("/");

          if (routeParts.length === pathnameParts.length) {
            let isMatch = true;

            for (let i = 0; i < routeParts.length; i++) {
              if (routeParts[i].startsWith(":")) continue;
              if (routeParts[i] !== pathnameParts[i]) {
                isMatch = false;
                break;
              }
            }

            if (isMatch) {
              setCurrentComponent(route.component);
              return;
            }
          }
        }
      }

      // Default to the first route if no match (or could be a 404 component)
      setCurrentComponent(routes[0]?.component || null);
    };

    matchRoute();
  }, [pathname, routes]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-lg">Loading...</p>
      </div>
    );
  }

  return <AdminLayout>{currentComponent}</AdminLayout>;
}
