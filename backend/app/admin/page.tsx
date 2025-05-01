"use client";

import { useState, useEffect } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function AdminDashboard() {
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

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

  async function handleSignOut() {
    await supabase.auth.signOut();
    router.push("/auth/login");
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p className="text-lg">Loading...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <nav className="border-b">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-xl font-bold">BacaKomik Admin</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">{user?.email}</span>
            <Button variant="destructive" onClick={handleSignOut} size="sm">
              Logout
            </Button>
          </div>
        </div>
      </nav>

      <div className="container mx-auto p-4 md:p-6">
        <h2 className="text-2xl font-bold mb-6">Dashboard</h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Manajemen Komik</CardTitle>
              <CardDescription>
                Kelola data komik, chapter, dan pages
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Tambah, edit, atau hapus komik dan chapter
              </p>
            </CardContent>
            <CardFooter>
              <Button
                onClick={() => router.push("/admin/comics")}
                className="w-full"
              >
                Buka
              </Button>
            </CardFooter>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Manajemen Metadata</CardTitle>
              <CardDescription>
                Kelola genre, author, artist, dan format
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Tambah, edit, atau hapus metadata komik
              </p>
            </CardContent>
            <CardFooter>
              <Button
                onClick={() => router.push("/admin/metadata")}
                className="w-full"
              >
                Buka
              </Button>
            </CardFooter>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Konten Unggulan</CardTitle>
              <CardDescription>
                Atur rekomendasi dan konten populer
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Tetapkan komik populer dan rekomendasi
              </p>
            </CardContent>
            <CardFooter>
              <Button
                onClick={() => router.push("/admin/featured")}
                className="w-full"
              >
                Buka
              </Button>
            </CardFooter>
          </Card>
        </div>
      </div>
    </div>
  );
}
