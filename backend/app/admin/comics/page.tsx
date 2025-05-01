"use client";

import { useState, useEffect } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import Link from "next/link";

interface Comic {
  id: string;
  title: string;
  alternative_title: string | null;
  country_id: string;
  release_year: number | null;
  view_count: number | null;
  vote_count: number | null;
  bookmark_count: number | null;
}

export default function Comics() {
  const [comics, setComics] = useState<Comic[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

  useEffect(() => {
    // Verifikasi autentikasi
    async function checkAuth() {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session) {
        router.push("/auth/login");
        return false;
      }
      return true;
    }

    // Ambil data komik
    async function fetchComics() {
      setLoading(true);

      const isAuthenticated = await checkAuth();
      if (!isAuthenticated) return;

      try {
        let query = supabase.from("mKomik").select("*").order("title");

        const { data, error } = await query;

        if (error) {
          console.error("Error fetching comics:", error);
          return;
        }

        setComics(data as Comic[]);
      } catch (error) {
        console.error("Unexpected error:", error);
      } finally {
        setLoading(false);
      }
    }

    fetchComics();
  }, [router, supabase]);

  // Fungsi pencarian
  const filteredComics = comics.filter(
    (comic) =>
      comic.title.toLowerCase().includes(search.toLowerCase()) ||
      (comic.alternative_title &&
        comic.alternative_title.toLowerCase().includes(search.toLowerCase()))
  );

  return (
    <div className="p-4 md:p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Manajemen Komik</h1>
          <p className="text-sm text-muted-foreground">
            Kelola daftar komik yang tersedia
          </p>
        </div>
        <Button onClick={() => router.push("/admin")}>
          Kembali ke Dashboard
        </Button>
      </div>

      <Card className="mb-6">
        <CardHeader className="pb-3">
          <CardTitle>Daftar Komik</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-between mb-4">
            <div className="w-full max-w-sm">
              <Input
                placeholder="Cari komik..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full"
              />
            </div>
            <Button onClick={() => router.push("/admin/comics/add")}>
              Tambah Komik
            </Button>
          </div>

          {loading ? (
            <div className="py-8 text-center">Loading...</div>
          ) : (
            <div className="overflow-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Judul</TableHead>
                    <TableHead>Judul Alternatif</TableHead>
                    <TableHead>Negara</TableHead>
                    <TableHead>Tahun</TableHead>
                    <TableHead className="text-right">Views</TableHead>
                    <TableHead className="text-right">Votes</TableHead>
                    <TableHead className="text-right">Bookmarks</TableHead>
                    <TableHead>Aksi</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredComics.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={8} className="text-center py-8">
                        Tidak ada komik yang ditemukan
                      </TableCell>
                    </TableRow>
                  ) : (
                    filteredComics.map((comic) => (
                      <TableRow key={comic.id}>
                        <TableCell className="font-medium">
                          {comic.title}
                        </TableCell>
                        <TableCell>{comic.alternative_title || "-"}</TableCell>
                        <TableCell>{comic.country_id}</TableCell>
                        <TableCell>{comic.release_year || "-"}</TableCell>
                        <TableCell className="text-right">
                          {comic.view_count || 0}
                        </TableCell>
                        <TableCell className="text-right">
                          {comic.vote_count || 0}
                        </TableCell>
                        <TableCell className="text-right">
                          {comic.bookmark_count || 0}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center space-x-2">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() =>
                                router.push(`/admin/comics/edit/${comic.id}`)
                              }
                            >
                              Edit
                            </Button>
                            <Link href={`/admin/comics/${comic.id}/chapters`}>
                              <Button variant="outline" size="sm">
                                Chapters
                              </Button>
                            </Link>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
