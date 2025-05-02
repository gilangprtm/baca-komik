"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  ChevronLeft,
  Users,
  BookMarked,
  ThumbsUp,
  MessageSquare,
  Clock,
  UserCheck,
  Loader2,
} from "lucide-react";

// Tipe data untuk statistik user
type UserStats = {
  totalUsers: number;
  activeUsers: number; // Active in last 30 days
  bookmarksPerUser: number;
  commentsPerUser: number;
  votesPerUser: number;
};

// Tipe data untuk user aktif
type ActiveUser = {
  id: string;
  name: string;
  avatar_url: string | null;
  commentCount: number;
  voteCount: number;
  bookmarkCount: number;
  lastActive: string;
};

export default function EngagementAnalytics() {
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

  // State untuk data
  const [userStats, setUserStats] = useState<UserStats | null>(null);
  const [activeUsers, setActiveUsers] = useState<ActiveUser[]>([]);
  const [retentionData, setRetentionData] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState("overview");

  // State untuk loading
  const [isLoadingStats, setIsLoadingStats] = useState(true);
  const [isLoadingActiveUsers, setIsLoadingActiveUsers] = useState(true);
  const [isLoadingRetention, setIsLoadingRetention] = useState(true);

  // Fetch statistik user
  const fetchUserStats = async () => {
    setIsLoadingStats(true);
    try {
      // Dapatkan jumlah total user
      const { count: totalUsers, error: usersError } = await supabase
        .from("mUser")
        .select("*", { count: "exact", head: true });

      if (usersError) throw usersError;

      // Dapatkan jumlah user aktif (simulasi dengan data hardcoded)
      // Di implementasi nyata: filter berdasarkan timestamp dari aktivitas terakhir
      const activeUsers = Math.floor(totalUsers || 0 * 0.7); // Asumsi 70% user aktif

      // Dapatkan jumlah total bookmarks
      const { count: totalBookmarks, error: bookmarksError } = await supabase
        .from("trUserBookmark")
        .select("*", { count: "exact", head: true });

      if (bookmarksError) throw bookmarksError;

      // Dapatkan jumlah total votes pada komik
      const { count: totalComicVotes, error: comicVotesError } = await supabase
        .from("mKomikVote")
        .select("*", { count: "exact", head: true });

      if (comicVotesError) throw comicVotesError;

      // Dapatkan jumlah total votes pada chapter
      const { count: totalChapterVotes, error: chapterVotesError } =
        await supabase
          .from("trChapterVote")
          .select("*", { count: "exact", head: true });

      if (chapterVotesError) throw chapterVotesError;

      // Dapatkan jumlah total komentar
      const { count: totalComments, error: commentsError } = await supabase
        .from("trComments")
        .select("*", { count: "exact", head: true });

      if (commentsError) throw commentsError;

      // Hitung metrik per user
      const totalVotes = (totalComicVotes || 0) + (totalChapterVotes || 0);
      const userCount = totalUsers || 1; // Hindari pembagian dengan nol

      setUserStats({
        totalUsers: totalUsers || 0,
        activeUsers: activeUsers || 0,
        bookmarksPerUser: totalBookmarks ? totalBookmarks / userCount : 0,
        commentsPerUser: totalComments ? totalComments / userCount : 0,
        votesPerUser: totalVotes ? totalVotes / userCount : 0,
      });
    } catch (error) {
      console.error("Error fetching user stats:", error);
      alert("Failed to load user statistics. Please try again.");
    } finally {
      setIsLoadingStats(false);
    }
  };

  // Fetch data user aktif (simulasi)
  const fetchActiveUsers = async () => {
    setIsLoadingActiveUsers(true);
    try {
      // Dapatkan daftar user
      const { data: users, error } = await supabase
        .from("mUser")
        .select("id, name, avatar_url")
        .limit(10);

      if (error) throw error;

      // Simulasi data aktivitas karena tidak punya timestamp aktivitas di skema
      const activeUsers = users.map((user) => ({
        ...user,
        commentCount: Math.floor(Math.random() * 20),
        voteCount: Math.floor(Math.random() * 50),
        bookmarkCount: Math.floor(Math.random() * 30),
        lastActive: new Date(
          Date.now() - Math.floor(Math.random() * 7 * 24 * 60 * 60 * 1000)
        ).toISOString(),
      }));

      setActiveUsers(activeUsers);
    } catch (error) {
      console.error("Error fetching active users:", error);
      alert("Failed to load active users. Please try again.");
    } finally {
      setIsLoadingActiveUsers(false);
    }
  };

  // Fetch data retensi (simulasi)
  const fetchRetentionData = async () => {
    setIsLoadingRetention(true);
    try {
      // Di implementasi nyata: Query kompleks untuk mendapatkan retensi mingguan
      // Untuk contoh ini, kita buat data dummy

      const weeks = 10;
      const retentionData = Array.from({ length: weeks }, (_, i) => ({
        week: `Week ${i + 1}`,
        retention: 100 - i * (100 / weeks) * Math.random() * 0.5,
      }));

      setRetentionData(retentionData);
    } catch (error) {
      console.error("Error fetching retention data:", error);
      alert("Failed to load retention data. Please try again.");
    } finally {
      setIsLoadingRetention(false);
    }
  };

  // Handler untuk perubahan tab
  const handleTabChange = (value: string) => {
    setActiveTab(value);
  };

  // Handler untuk kembali ke halaman admin
  const navigateBack = () => {
    router.push(`/admin?view=analytics-overview`);
  };

  // Initial load
  useEffect(() => {
    fetchUserStats();
    fetchActiveUsers();
    fetchRetentionData();
  }, []);

  // Format angka menjadi 1 digit desimal
  const formatDecimal = (num: number) => {
    return num.toFixed(1);
  };

  // Format tanggal menjadi readable
  const formatDate = (isoDate: string) => {
    return new Date(isoDate).toLocaleDateString("id-ID", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">User Engagement Analytics</h1>
          <p className="text-muted-foreground">
            Track how users interact with your content
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          <ChevronLeft className="h-4 w-4 mr-2" />
          Back to Analytics
        </Button>
      </div>

      <Tabs
        defaultValue="overview"
        className="w-full"
        onValueChange={handleTabChange}
      >
        <TabsList className="grid grid-cols-3 mb-4">
          <TabsTrigger value="overview" className="flex items-center">
            <Users className="h-4 w-4 mr-2" />
            User Overview
          </TabsTrigger>
          <TabsTrigger value="active" className="flex items-center">
            <UserCheck className="h-4 w-4 mr-2" />
            Active Users
          </TabsTrigger>
          <TabsTrigger value="retention" className="flex items-center">
            <Clock className="h-4 w-4 mr-2" />
            Retention
          </TabsTrigger>
        </TabsList>

        {/* Tab User Overview */}
        <TabsContent value="overview">
          {isLoadingStats ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : userStats ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
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
                      {userStats.totalUsers.toLocaleString()}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Active Users
                  </CardTitle>
                  <CardDescription>Last 30 days</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <UserCheck className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {userStats.activeUsers.toLocaleString()}
                    </div>
                  </div>
                  {userStats.totalUsers > 0 && (
                    <p className="text-xs text-muted-foreground mt-1">
                      {(
                        (userStats.activeUsers / userStats.totalUsers) *
                        100
                      ).toFixed(1)}
                      % of total users
                    </p>
                  )}
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Bookmarks per User
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <BookMarked className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {formatDecimal(userStats.bookmarksPerUser)}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Comments per User
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <MessageSquare className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {formatDecimal(userStats.commentsPerUser)}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Votes per User
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center">
                    <ThumbsUp className="h-4 w-4 text-muted-foreground mr-2" />
                    <div className="text-2xl font-bold">
                      {formatDecimal(userStats.votesPerUser)}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm font-medium">
                    Engagement Score
                  </CardTitle>
                  <CardDescription>Combined metric</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {formatDecimal(
                      (userStats.bookmarksPerUser +
                        userStats.commentsPerUser * 3 +
                        userStats.votesPerUser) /
                        5
                    )}
                  </div>
                  <p className="text-xs text-muted-foreground mt-1">
                    Based on user actions weighted by importance
                  </p>
                </CardContent>
              </Card>
            </div>
          ) : (
            <p>No user statistics available. Please try again later.</p>
          )}
        </TabsContent>

        {/* Tab Active Users */}
        <TabsContent value="active">
          {isLoadingActiveUsers ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : (
            <Card>
              <CardHeader>
                <CardTitle>Most Active Users</CardTitle>
                <CardDescription>Users with highest engagement</CardDescription>
              </CardHeader>
              <CardContent className="p-0">
                {activeUsers.length > 0 ? (
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="border-b">
                          <th className="px-4 py-2 text-left">User</th>
                          <th className="px-4 py-2 text-center">Comments</th>
                          <th className="px-4 py-2 text-center">Votes</th>
                          <th className="px-4 py-2 text-center">Bookmarks</th>
                          <th className="px-4 py-2 text-center">Last Active</th>
                        </tr>
                      </thead>
                      <tbody>
                        {activeUsers
                          .sort(
                            (a, b) =>
                              b.commentCount +
                              b.voteCount +
                              b.bookmarkCount -
                              (a.commentCount + a.voteCount + a.bookmarkCount)
                          )
                          .map((user) => (
                            <tr key={user.id} className="border-b">
                              <td className="px-4 py-2">
                                <div className="flex items-center gap-2">
                                  <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                                    {user.avatar_url ? (
                                      <img
                                        src={user.avatar_url}
                                        alt={user.name}
                                        className="w-full h-full object-cover"
                                      />
                                    ) : (
                                      <Users className="h-4 w-4" />
                                    )}
                                  </div>
                                  <span className="font-medium">
                                    {user.name}
                                  </span>
                                </div>
                              </td>
                              <td className="px-4 py-2 text-center">
                                {user.commentCount}
                              </td>
                              <td className="px-4 py-2 text-center">
                                {user.voteCount}
                              </td>
                              <td className="px-4 py-2 text-center">
                                {user.bookmarkCount}
                              </td>
                              <td className="px-4 py-2 text-center">
                                {formatDate(user.lastActive)}
                              </td>
                            </tr>
                          ))}
                      </tbody>
                    </table>
                  </div>
                ) : (
                  <p className="p-4">No active user data available.</p>
                )}
              </CardContent>
            </Card>
          )}
        </TabsContent>

        {/* Tab Retention */}
        <TabsContent value="retention">
          {isLoadingRetention ? (
            <div className="flex justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : (
            <Card>
              <CardHeader>
                <CardTitle>User Retention</CardTitle>
                <CardDescription>Weekly retention rates</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {retentionData.length > 0 ? (
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
                      <table className="w-full">
                        <thead>
                          <tr className="text-xs text-muted-foreground bg-muted">
                            <th className="px-4 py-2 text-left">Period</th>
                            <th className="px-4 py-2 text-right">
                              Retention Rate
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {retentionData.map((data) => (
                            <tr key={data.week} className="border-b">
                              <td className="px-4 py-2">{data.week}</td>
                              <td className="px-4 py-2 text-right">
                                {data.retention.toFixed(1)}%
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </>
                ) : (
                  <p>No retention data available.</p>
                )}
              </CardContent>
            </Card>
          )}
        </TabsContent>
      </Tabs>
    </>
  );
}
