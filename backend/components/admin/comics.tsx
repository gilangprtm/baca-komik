"use client";

import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import Link from "next/link";
import { useEffect, useState } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter } from "next/navigation";

export default function ComicsContent() {
  const router = useRouter();
  const [comics, setComics] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const supabase = createClientComponentClient();

  useEffect(() => {
    async function fetchComics() {
      setLoading(true);

      try {
        // In a real app, this would fetch from your Supabase table
        // const { data, error } = await supabase.from("comics").select("*");
        // if (error) throw error;
        // setComics(data || []);

        // For demo purposes, using sample data
        setComics([
          {
            id: 1,
            title: "One Piece",
            status: "ongoing",
            chapters: 1102,
            views: 32563,
          },
          {
            id: 2,
            title: "Jujutsu Kaisen",
            status: "ongoing",
            chapters: 234,
            views: 18923,
          },
          {
            id: 3,
            title: "Naruto",
            status: "completed",
            chapters: 700,
            views: 29437,
          },
          {
            id: 4,
            title: "Demon Slayer",
            status: "completed",
            chapters: 205,
            views: 21854,
          },
          {
            id: 5,
            title: "Attack on Titan",
            status: "completed",
            chapters: 139,
            views: 27652,
          },
        ]);
      } catch (error) {
        console.error("Error fetching comics:", error);
      } finally {
        setLoading(false);
      }
    }

    fetchComics();
  }, [supabase]);

  const filteredComics = comics.filter((comic) =>
    comic.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Handle SPA navigation
  const navigateTo = (view: string) => {
    router.push(`/admin?view=${view}`);
  };

  const navigateToEdit = (id: number) => {
    router.push(`/admin?view=comics-edit&id=${id}`);
  };

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Comics</h1>
        <Button onClick={() => navigateTo("comics-new")}>Add New Comic</Button>
      </div>

      <div className="mb-4">
        <Input
          placeholder="Search comics..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Chapters</TableHead>
              <TableHead>Views</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8">
                  Loading...
                </TableCell>
              </TableRow>
            ) : filteredComics.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8">
                  No comics found
                </TableCell>
              </TableRow>
            ) : (
              filteredComics.map((comic) => (
                <TableRow key={comic.id}>
                  <TableCell className="font-medium">{comic.title}</TableCell>
                  <TableCell>
                    <span
                      className={`px-2 py-1 rounded-full text-xs ${
                        comic.status === "ongoing"
                          ? "bg-green-100 text-green-800"
                          : "bg-blue-100 text-blue-800"
                      }`}
                    >
                      {comic.status}
                    </span>
                  </TableCell>
                  <TableCell>{comic.chapters}</TableCell>
                  <TableCell>{comic.views.toLocaleString()}</TableCell>
                  <TableCell>
                    <div className="flex gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => navigateToEdit(comic.id)}
                      >
                        Edit
                      </Button>
                      <Button variant="destructive" size="sm">
                        Delete
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </>
  );
}
