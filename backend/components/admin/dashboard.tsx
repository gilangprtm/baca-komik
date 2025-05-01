"use client";

import { useEffect, useState } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import { BookOpen, Users, Eye } from "lucide-react";

// Define types for our data
type ComicType = {
  id: string;
  title: string;
  cover_image_url: string | null;
  view_count: number | null;
  bookmark_count: number | null;
};

export default function DashboardContent() {
  const [stats, setStats] = useState({
    totalComics: 0,
    totalUsers: 0,
    totalViews: 0,
    popularComics: [] as ComicType[],
  });
  const [recentActivities, setRecentActivities] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const supabase = createClientComponentClient<Database>();

  useEffect(() => {
    async function fetchDashboardData() {
      setLoading(true);
      try {
        // Fetch total comics count
        const { count: comicsCount, error: comicsError } = await supabase
          .from("mKomik")
          .select("*", { count: "exact", head: true });

        // Fetch total users count
        const { count: usersCount, error: usersError } = await supabase
          .from("mUser")
          .select("*", { count: "exact", head: true });

        // Get total views (sum of view_count from all comics)
        const { data: viewsData, error: viewsError } = await supabase
          .from("mKomik")
          .select("view_count");

        const totalViews =
          viewsData?.reduce((sum, comic) => sum + (comic.view_count || 0), 0) ||
          0;

        // Get recent chapters
        const { data: recentChapters, error: chaptersError } = await supabase
          .from("mChapter")
          .select(
            `
            id,
            chapter_number,
            release_date,
            mKomik:id_komik(id, title, cover_image_url)
          `
          )
          .order("release_date", { ascending: false })
          .limit(5);

        // Get popular comics
        const { data: popularComics, error: popularError } = await supabase
          .from("mKomik")
          .select(
            `
            id, 
            title, 
            cover_image_url, 
            view_count, 
            bookmark_count
          `
          )
          .order("view_count", { ascending: false })
          .limit(3);

        if (
          comicsError ||
          usersError ||
          viewsError ||
          chaptersError ||
          popularError
        ) {
          console.error(
            "Error fetching dashboard data:",
            comicsError ||
              usersError ||
              viewsError ||
              chaptersError ||
              popularError
          );
          return;
        }

        setStats({
          totalComics: comicsCount || 0,
          totalUsers: usersCount || 0,
          totalViews: totalViews,
          popularComics: popularComics || [],
        });

        setRecentActivities(recentChapters || []);
      } catch (error) {
        console.error("Unexpected error:", error);
      } finally {
        setLoading(false);
      }
    }

    fetchDashboardData();
  }, [supabase]);

  // Format date for display
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();

    // Calculate time difference in milliseconds
    const diff = now.getTime() - date.getTime();

    // Convert to hours
    const hours = Math.floor(diff / (1000 * 60 * 60));

    if (hours < 24) {
      return `${hours} jam yang lalu`;
    } else if (hours < 48) {
      return `Kemarin`;
    } else {
      return new Intl.DateTimeFormat("id-ID", {
        day: "numeric",
        month: "long",
        year: "numeric",
      }).format(date);
    }
  };

  return (
    <>
      <div className="grid auto-rows-min gap-4 md:grid-cols-3">
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <div className="flex items-center gap-2 mb-2">
            <BookOpen className="h-5 w-5 text-primary" />
            <h3 className="text-xl font-semibold">Total Komik</h3>
          </div>
          {loading ? (
            <div className="animate-pulse h-9 bg-muted rounded"></div>
          ) : (
            <p className="text-3xl font-bold">
              {stats.totalComics.toLocaleString()}
            </p>
          )}
        </div>
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <div className="flex items-center gap-2 mb-2">
            <Users className="h-5 w-5 text-primary" />
            <h3 className="text-xl font-semibold">Total Pengguna</h3>
          </div>
          {loading ? (
            <div className="animate-pulse h-9 bg-muted rounded"></div>
          ) : (
            <p className="text-3xl font-bold">
              {stats.totalUsers.toLocaleString()}
            </p>
          )}
        </div>
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <div className="flex items-center gap-2 mb-2">
            <Eye className="h-5 w-5 text-primary" />
            <h3 className="text-xl font-semibold">Total Pembacaan</h3>
          </div>
          {loading ? (
            <div className="animate-pulse h-9 bg-muted rounded"></div>
          ) : (
            <p className="text-3xl font-bold">
              {stats.totalViews.toLocaleString()}
            </p>
          )}
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3 mt-4">
        <div className="md:col-span-2 bg-muted/50 min-h-[400px] flex-1 rounded-xl p-6 md:min-h-min">
          <h2 className="text-2xl font-bold mb-4">Aktivitas Terbaru</h2>
          <div className="space-y-4">
            {loading ? (
              Array(3)
                .fill(0)
                .map((_, i) => (
                  <div key={i} className="p-4 bg-background rounded-lg">
                    <div className="animate-pulse space-y-2">
                      <div className="h-4 bg-muted rounded w-3/4"></div>
                      <div className="h-3 bg-muted rounded w-1/4"></div>
                    </div>
                  </div>
                ))
            ) : recentActivities.length === 0 ? (
              <div className="p-4 bg-background rounded-lg">
                <p className="text-muted-foreground">
                  Belum ada aktivitas terbaru.
                </p>
              </div>
            ) : (
              recentActivities.map((activity) => (
                <div
                  key={activity.id}
                  className="p-4 bg-background rounded-lg flex items-center gap-3"
                >
                  {activity.mKomik?.cover_image_url && (
                    <div className="flex-shrink-0 w-12 h-12 rounded overflow-hidden">
                      <img
                        src={activity.mKomik.cover_image_url}
                        alt={activity.mKomik?.title}
                        className="w-full h-full object-cover"
                      />
                    </div>
                  )}
                  <div>
                    <p className="font-medium">
                      Chapter baru: {activity.mKomik?.title} Chapter{" "}
                      {activity.chapter_number}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {formatDate(activity.release_date)}
                    </p>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="bg-muted/50 min-h-[400px] flex-1 rounded-xl p-6 md:min-h-min">
          <h2 className="text-2xl font-bold mb-4">Komik Populer</h2>
          <div className="space-y-4">
            {loading ? (
              Array(3)
                .fill(0)
                .map((_, i) => (
                  <div key={i} className="p-4 bg-background rounded-lg">
                    <div className="animate-pulse space-y-2">
                      <div className="h-4 bg-muted rounded w-3/4"></div>
                      <div className="h-3 bg-muted rounded w-1/4"></div>
                    </div>
                  </div>
                ))
            ) : stats.popularComics.length === 0 ? (
              <div className="p-4 bg-background rounded-lg">
                <p className="text-muted-foreground">
                  Belum ada data komik populer.
                </p>
              </div>
            ) : (
              stats.popularComics.map((comic: any) => (
                <div
                  key={comic.id}
                  className="p-4 bg-background rounded-lg flex items-center gap-3"
                >
                  {comic.cover_image_url && (
                    <div className="flex-shrink-0 w-12 h-16 rounded overflow-hidden">
                      <img
                        src={comic.cover_image_url}
                        alt={comic.title}
                        className="w-full h-full object-cover"
                      />
                    </div>
                  )}
                  <div>
                    <p className="font-medium line-clamp-1">{comic.title}</p>
                    <div className="flex text-sm text-muted-foreground gap-3">
                      <p>{comic.view_count?.toLocaleString() || 0} views</p>
                      <p>
                        {comic.bookmark_count?.toLocaleString() || 0} bookmarks
                      </p>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </>
  );
}
