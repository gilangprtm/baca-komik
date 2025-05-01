"use client";

import { useState, useEffect } from "react";
import { createBrowserSupabaseClient } from "@/lib/supabase/client";
import { Database } from "@/lib/supabase/database.types";

type Comic = Database["public"]["Tables"]["mKomik"]["Row"];

export default function ComicList() {
  const [comics, setComics] = useState<Comic[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchComics = async () => {
      try {
        setLoading(true);
        const supabase = createBrowserSupabaseClient();
        const { data, error } = await supabase
          .from("mKomik")
          .select("*")
          .order("rank", { ascending: false })
          .limit(10);

        if (error) {
          throw new Error(error.message);
        }

        setComics(data || []);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error occurred");
      } finally {
        setLoading(false);
      }
    };

    fetchComics();
  }, []);

  if (loading) return <div>Loading comics...</div>;
  if (error) return <div>Error: {error}</div>;
  if (comics.length === 0) return <div>No comics found</div>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {comics.map((comic) => (
        <div key={comic.id} className="border rounded-md p-4 shadow">
          <h2 className="text-xl font-bold">{comic.title}</h2>
          {comic.alternative_title && (
            <p className="text-sm text-gray-500">{comic.alternative_title}</p>
          )}
          {comic.cover_image_url && (
            <img
              src={comic.cover_image_url}
              alt={comic.title}
              className="w-full h-52 object-cover my-3 rounded"
            />
          )}
          <div className="mt-2">
            <p className="text-sm truncate">
              {comic.description || "No description available"}
            </p>
            <div className="flex justify-between mt-3 text-sm text-gray-600">
              <span>Views: {comic.view_count}</span>
              <span>Votes: {comic.vote_count}</span>
              <span>Bookmarks: {comic.bookmark_count}</span>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
