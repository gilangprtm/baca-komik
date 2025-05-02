"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  ChevronLeft,
  TrendingUp,
  BookOpen,
  Users,
  Eye,
  ThumbsUp,
  BarChart3,
  BookMarked,
  MessageSquare,
  Calendar,
  Loader2,
} from "lucide-react";

// Tipe data untuk statistik dasar
type OverviewStats = {
  totalComics: number;
  totalChapters: number;
  totalUsers: number;
  totalViews: number;
  totalVotes: number;
  totalBookmarks: number;
  totalComments: number;
};

// Tipe data untuk komik populer
type PopularComic = {
  id: string;
  title: string;
  view_count: number | null;
  vote_count: number | null;
  cover_image_url: string | null;
};

// Tipe data untuk statistik waktu
type TimeStats = {
  date: string;
  views: number;
  votes: number;
  comments: number;
};

export default function AnalyticsOverview() {
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

  // State untuk data
  const [overviewStats, setOverviewStats] = useState<OverviewStats | null>(
    null
  );
  const [popularComics, setPopularComics] = useState<PopularComic[]>([]);
  const [timeStats, setTimeStats] = useState<TimeStats[]>([]);
  const [activeTab, setActiveTab] = useState("overview");

  // State untuk loading
  const [isLoadingOverview, setIsLoadingOverview] = useState(true);
  const [isLoadingPopular, setIsLoadingPopular] = useState(true);
  const [isLoadingTimeStats, setIsLoadingTimeStats] = useState(true);

  // Fetch data overview
  const fetchOverviewStats = async () => {
    setIsLoadingOverview(true);
    try {
      // Dapatkan jumlah total komik
      const { count: totalComics, error: comicsError } = await supabase
        .from("mKomik")
        .select("*", { count: "exact", head: true });

      if (comicsError) throw comicsError;

      // Dapatkan jumlah total chapter
      const { count: totalChapters, error: chaptersError } = await supabase
        .from("mChapter")
        .select("*", { count: "exact", head: true });

      if (chaptersError) throw chaptersError;

      // Dapatkan jumlah total user
      const { count: totalUsers, error: usersError } = await supabase
        .from("mUser")
        .select("*", { count: "exact", head: true });

      if (usersError) throw usersError;

      // Dapatkan jumlah total komentar
      const { count: totalComments, error: commentsError } = await supabase
        .from("trComments")
        .select("*", { count: "exact", head: true });

      if (commentsError) throw commentsError;

      // Dapatkan jumlah total bookmark
      const { count: totalBookmarks, error: bookmarksError } = await supabase
        .from("trUserBookmark")
        .select("*", { count: "exact", head: true });

      if (bookmarksError) throw bookmarksError;

      // Dapatkan total view dan vote dari tabel mKomik
      const { data: totalData, error: totalError } = await supabase
        .from("mKomik")
        .select("view_count, vote_count");

      if (totalError) throw totalError;

      // Hitung total views dan votes
      const totalViews = totalData.reduce(
        (sum, comic) => sum + (comic.view_count || 0),
        0
      );
      const totalVotes = totalData.reduce(
        (sum, comic) => sum + (comic.vote_count || 0),
        0
      );

      // Set data overview
      setOverviewStats({
        totalComics: totalComics || 0,
        totalChapters: totalChapters || 0,
        totalUsers: totalUsers || 0,
        totalViews: totalViews || 0,
        totalVotes: totalVotes || 0,
        totalBookmarks: totalBookmarks || 0,
        totalComments: totalComments || 0,
      });
    } catch (error) {
      console.error("Error fetching overview stats:", error);
      alert("Failed to load overview statistics. Please try again.");
    } finally {
      setIsLoadingOverview(false);
    }
  };

  // Fetch komik populer
  const fetchPopularComics = async () => {
    setIsLoadingPopular(true);
    try {
      // Dapatkan top 10 komik berdasarkan view_count
      const { data, error } = await supabase
        .from("mKomik")
        .select("id, title, view_count, vote_count, cover_image_url")
        .order("view_count", { ascending: false })
        .limit(10);

      if (error) throw error;

      setPopularComics(data || []);
    } catch (error) {
      console.error("Error fetching popular comics:", error);
      alert("Failed to load popular comics. Please try again.");
    } finally {
      setIsLoadingPopular(false);
    }
  };

  // Fetch time-based stats (simulasi data untuk contoh)
  const fetchTimeStats = async () => {
    setIsLoadingTimeStats(true);
    try {
      // Di sini kita bisa membuat query yang lebih kompleks untuk mendapatkan
      // statistik berdasarkan waktu dari database
      // Untuk contoh ini, kita buat data dummy

      // Mendapatkan tanggal 30 hari terakhir
      const last30Days = Array.from({ length: 30 }, (_, i) => {
        const date = new Date();
        date.setDate(date.getDate() - i);
        return date.toISOString().split("T")[0];
      }).reverse();

      // Buat data dummy untuk contoh
      const dummyTimeStats = last30Days.map((date) => ({
        date,
        views: Math.floor(Math.random() * 1000),
        votes: Math.floor(Math.random() * 100),
        comments: Math.floor(Math.random() * 50),
      }));

      setTimeStats(dummyTimeStats);
    } catch (error) {
      console.error("Error fetching time stats:", error);
      alert("Failed to load time statistics. Please try again.");
    } finally {
      setIsLoadingTimeStats(false);
    }
  };

  // Handler untuk perubahan tab
  const handleTabChange = (value: string) => {
    setActiveTab(value);
  };

  // Handler untuk kembali ke halaman admin
  const navigateBack = () => {
    router.push(`/admin`);
  };

  // Initial load
  useEffect(() => {
    fetchOverviewStats();
    fetchPopularComics();
    fetchTimeStats();
  }, []);

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Analytics Dashboard</h1>
          <p className="text-muted-foreground">
            Monitor platform performance and user engagement
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          <ChevronLeft className="h-4 w-4 mr-2" />
          Back to Admin
        </Button>
      </div>

      <Tabs
        defaultValue="overview"
        className="w-full"
        onValueChange={handleTabChange}
      >
        <TabsList className="grid grid-cols-3 mb-4">
          <TabsTrigger value="overview" className="flex items-center">
            <BarChart3 className="h-4 w-4 mr-2" />
            Overview
          </TabsTrigger>
          <TabsTrigger value="popular" className="flex items-center">
            <TrendingUp className="h-4 w-4 mr-2" />
            Popular Content
          </TabsTrigger>
          <TabsTrigger value="timeline" className="flex items-center">
            <Calendar className="h-4 w-4 mr-2" />
            Timeline Stats
          </TabsTrigger>
        </TabsList>

        {/* Tab Overview */}
        <TabsContent value="overview">
          {isLoadingOverview ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : overviewStats ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Comics
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <BookOpen className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalComics.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Chapters
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <BookOpen className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalChapters.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Users
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <Users className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalUsers.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Views
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <Eye className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalViews.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Votes
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <ThumbsUp className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalVotes.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Bookmarks
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <BookMarked className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalBookmarks.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Total Comments
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <MessageSquare className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {overviewStats.totalComments.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Engagement Rate
                  </CardTitle>
                  <CardDescription>Votes per View</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {overviewStats.totalViews > 0
                      ? (
                          (overviewStats.totalVotes /
                            overviewStats.totalViews) *
                          100
                        ).toFixed(2) + "%"
                      : "0%"}
                  </div>
                </CardContent>
              </Card>
            </div>
          ) : (
            <p>No statistics available. Please try again later.</p>
          )}
        </TabsContent>

        {/* Tab Popular Content */}
        <TabsContent value="popular">
          {isLoadingPopular ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Card>
                <CardHeader>
                  <CardTitle>Top 10 Comics by Views</CardTitle>
                  <CardDescription>
                    Comics with the highest number of views
                  </CardDescription>
                </CardHeader>
                <CardContent className="p-0">
                  {popularComics.length > 0 ? (
                    <div className="divide-y">
                      {popularComics.map((comic, index) => (
                        <div key={comic.id} className="flex items-center p-4">
                          <div className="font-bold text-xl min-w-[2rem] text-muted-foreground">
                            {index + 1}.
                          </div>
                          {comic.cover_image_url && (
                            <img
                              src={comic.cover_image_url}
                              alt={comic.title}
                              className="h-12 w-10 object-cover rounded mx-2"
                            />
                          )}
                          <div className="flex-grow ml-2">
                            <p className="font-medium truncate">
                              {comic.title}
                            </p>
                            <div className="flex items-center gap-2 text-xs text-muted-foreground">
                              <span>
                                Views: {comic.view_count?.toLocaleString() || 0}
                              </span>
                              <span>•</span>
                              <span>
                                Votes: {comic.vote_count?.toLocaleString() || 0}
                              </span>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <p className="p-4">No comics data available.</p>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Top 10 Comics by Engagement</CardTitle>
                  <CardDescription>
                    Comics with highest engagement rate (votes/views)
                  </CardDescription>
                </CardHeader>
                <CardContent className="p-0">
                  {popularComics.length > 0 ? (
                    <div className="divide-y">
                      {[...popularComics]
                        .filter(
                          (comic) => comic.view_count && comic.view_count > 0
                        )
                        .sort((a, b) => {
                          const rateA =
                            (a.vote_count || 0) / (a.view_count || 1);
                          const rateB =
                            (b.vote_count || 0) / (b.view_count || 1);
                          return rateB - rateA;
                        })
                        .slice(0, 10)
                        .map((comic, index) => {
                          const engagementRate = comic.view_count
                            ? (
                                ((comic.vote_count || 0) / comic.view_count) *
                                100
                              ).toFixed(2) + "%"
                            : "0%";

                          return (
                            <div
                              key={comic.id}
                              className="flex items-center p-4"
                            >
                              <div className="font-bold text-xl min-w-[2rem] text-muted-foreground">
                                {index + 1}.
                              </div>
                              {comic.cover_image_url && (
                                <img
                                  src={comic.cover_image_url}
                                  alt={comic.title}
                                  className="h-12 w-10 object-cover rounded mx-2"
                                />
                              )}
                              <div className="flex-grow ml-2">
                                <p className="font-medium truncate">
                                  {comic.title}
                                </p>
                                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                                  <span>Engagement: {engagementRate}</span>
                                  <span>•</span>
                                  <span>
                                    Views:{" "}
                                    {comic.view_count?.toLocaleString() || 0}
                                  </span>
                                </div>
                              </div>
                            </div>
                          );
                        })}
                    </div>
                  ) : (
                    <p className="p-4">No comics data available.</p>
                  )}
                </CardContent>
              </Card>
            </div>
          )}
        </TabsContent>

        {/* Tab Timeline Stats */}
        <TabsContent value="timeline">
          {isLoadingTimeStats ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-4">
              <Card>
                <CardHeader>
                  <CardTitle>Activity Timeline (Last 30 Days)</CardTitle>
                  <CardDescription>
                    Daily views, votes, and comments
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-6">
                  {timeStats.length > 0 ? (
                    <>
                      <div className="relative border rounded-md p-6">
                        {/* Placeholder for chart - di implementasi nyata, gunakan chart library seperti ReCharts */}
                        <div className="text-center text-muted-foreground py-12">
                          <p>
                            Chart will be displayed here using a chart library.
                          </p>
                          <p className="text-sm mt-2">
                            We recommend using ReCharts or Chart.js for
                            implementation.
                          </p>
                        </div>
                      </div>

                      {/* Menampilkan data dalam tabel sebagai alternatif */}
                      <div className="overflow-x-auto rounded-md border">
                        <table className="w-full border-collapse">
                          <thead>
                            <tr className="text-xs text-muted-foreground bg-muted">
                              <th className="px-4 py-2 text-left">Date</th>
                              <th className="px-4 py-2 text-right">Views</th>
                              <th className="px-4 py-2 text-right">Votes</th>
                              <th className="px-4 py-2 text-right">Comments</th>
                            </tr>
                          </thead>
                          <tbody>
                            {timeStats
                              .slice(Math.max(timeStats.length - 7, 0))
                              .map((stat) => (
                                <tr
                                  key={stat.date}
                                  className="text-sm border-b"
                                >
                                  <td className="px-4 py-2">{stat.date}</td>
                                  <td className="px-4 py-2 text-right">
                                    {stat.views.toLocaleString()}
                                  </td>
                                  <td className="px-4 py-2 text-right">
                                    {stat.votes.toLocaleString()}
                                  </td>
                                  <td className="px-4 py-2 text-right">
                                    {stat.comments.toLocaleString()}
                                  </td>
                                </tr>
                              ))}
                          </tbody>
                        </table>
                        <div className="text-xs text-center py-2 text-muted-foreground bg-muted">
                          Showing last 7 days of data
                        </div>
                      </div>
                    </>
                  ) : (
                    <p>No timeline data available.</p>
                  )}
                </CardContent>
              </Card>
            </div>
          )}
        </TabsContent>
      </Tabs>
    </>
  );
}
