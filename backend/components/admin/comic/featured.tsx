"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
  CardFooter,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  ChevronLeft,
  Search,
  Loader2,
  ThumbsUp,
  Star,
  Clock,
  X,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";

type Comic = {
  id: string;
  title: string;
  cover_image_url: string | null;
  rank: number | null;
  view_count: number | null;
  vote_count: number | null;
  created_date: string | null;
};

// Define enum for period type
type PeriodType = "harian" | "mingguan" | "bulanan" | "all_time";

type PopularComic = {
  id_komik: string;
  type: PeriodType;
  comic?: Comic;
};

type RecommendedComic = {
  id_komik: string;
  comic?: Comic;
};

export default function FeaturedContent() {
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

  // State untuk Tab yang aktif
  const [activeTab, setActiveTab] = useState<string>("recommended");

  // State untuk Loading
  const [isLoadingRecommended, setIsLoadingRecommended] =
    useState<boolean>(false);
  const [isLoadingPopular, setIsLoadingPopular] = useState<boolean>(false);
  const [isLoadingComics, setIsLoadingComics] = useState<boolean>(false);

  // State untuk data
  const [recommendedComics, setRecommendedComics] = useState<
    RecommendedComic[]
  >([]);
  const [popularComics, setPopularComics] = useState<PopularComic[]>([]);
  const [availableComics, setAvailableComics] = useState<Comic[]>([]);

  // State untuk pencarian
  const [searchQuery, setSearchQuery] = useState<string>("");

  // State untuk popularitas type yang dipilih
  const [selectedPopularType, setSelectedPopularType] =
    useState<PeriodType>("harian");

  // Fungsi untuk fetch recommended comics
  const fetchRecommendedComics = async () => {
    setIsLoadingRecommended(true);
    try {
      // Fetch recommeded comics dengan join ke mKomik untuk mendapatkan detail komik
      const { data, error } = await supabase.from("mRecomed").select(`
        id_komik,
        comic:mKomik(
          id,
          title,
          cover_image_url,
          rank,
          view_count,
          vote_count,
          created_date
        )
      `);

      if (error) throw error;

      setRecommendedComics((data as RecommendedComic[]) || []);
    } catch (error) {
      console.error("Error fetching recommended comics:", error);
      alert("Failed to load recommended comics. Please try again.");
    } finally {
      setIsLoadingRecommended(false);
    }
  };

  // Fungsi untuk fetch popular comics berdasarkan type
  const fetchPopularComics = async (type: PeriodType) => {
    setIsLoadingPopular(true);
    try {
      // Fetch popular comics dengan type tertentu dan join ke mKomik
      const { data, error } = await supabase
        .from("mPopular")
        .select(
          `
          id_komik,
          type,
          comic:mKomik(
            id,
            title,
            cover_image_url,
            rank,
            view_count,
            vote_count,
            created_date
          )
        `
        )
        .eq("type", type);

      if (error) throw error;

      setPopularComics((data as PopularComic[]) || []);
    } catch (error) {
      console.error("Error fetching popular comics:", error);
      alert("Failed to load popular comics. Please try again.");
    } finally {
      setIsLoadingPopular(false);
    }
  };

  // Fungsi untuk fetch available comics (yang belum ada di rekomendasi/popular)
  const fetchAvailableComics = async () => {
    setIsLoadingComics(true);
    try {
      // Fetch komik yang tersedia untuk ditambahkan
      let query = supabase
        .from("mKomik")
        .select(
          "id, title, cover_image_url, rank, view_count, vote_count, created_date"
        );

      // Filter by search query jika ada
      if (searchQuery) {
        query = query.ilike("title", `%${searchQuery}%`);
        // Tetap mengurutkan berdasarkan judul untuk hasil pencarian
        query = query.order("title");
      } else {
        // Jika tidak ada pencarian, urutkan berdasarkan vote_count (tertinggi ke terendah)
        query = query.order("vote_count", { ascending: false });
      }

      // Batasi hanya 30 komik untuk performa yang lebih baik
      const { data, error } = await query.limit(30);

      if (error) throw error;

      setAvailableComics((data as Comic[]) || []);
    } catch (error) {
      console.error("Error fetching available comics:", error);
      alert("Failed to load available comics. Please try again.");
    } finally {
      setIsLoadingComics(false);
    }
  };

  // Handler untuk perubahan tab
  const handleTabChange = (value: string) => {
    setActiveTab(value);
    if (value === "recommended") {
      fetchRecommendedComics();
    } else if (value === "popular") {
      fetchPopularComics(selectedPopularType);
    }
    setSearchQuery("");
    fetchAvailableComics();
  };

  // Handler untuk perubahan type popular
  const handlePopularTypeChange = (value: PeriodType) => {
    setSelectedPopularType(value);
    fetchPopularComics(value);
  };

  // Handler untuk pencarian
  const handleSearch = () => {
    fetchAvailableComics();
  };

  // Handler untuk tambah ke rekomendasi
  const addToRecommended = async (comicId: string) => {
    try {
      // Periksa apakah sudah ada di rekomendasi
      const exists = recommendedComics.some((rc) => rc.id_komik === comicId);
      if (exists) {
        alert("Comic is already in recommended list.");
        return;
      }

      // Insert ke tabel mRecomed
      const { error } = await supabase
        .from("mRecomed")
        .insert({ id_komik: comicId });

      if (error) throw error;

      // Refresh data
      fetchRecommendedComics();
      alert("Comic added to recommended list.");
    } catch (error) {
      console.error("Error adding to recommended:", error);
      alert("Failed to add comic to recommended list. Please try again.");
    }
  };

  // Handler untuk tambah ke popular
  const addToPopular = async (comicId: string) => {
    try {
      // Periksa apakah sudah ada di popular dengan type yang sama
      const exists = popularComics.some(
        (pc) => pc.id_komik === comicId && pc.type === selectedPopularType
      );
      if (exists) {
        alert(`Comic is already in ${selectedPopularType} popular list.`);
        return;
      }

      // Insert ke tabel mPopular
      const { error } = await supabase
        .from("mPopular")
        .insert({ id_komik: comicId, type: selectedPopularType });

      if (error) throw error;

      // Refresh data
      fetchPopularComics(selectedPopularType);
      alert(`Comic added to ${selectedPopularType} popular list.`);
    } catch (error) {
      console.error("Error adding to popular:", error);
      alert("Failed to add comic to popular list. Please try again.");
    }
  };

  // Handler untuk hapus dari rekomendasi
  const removeFromRecommended = async (comicId: string) => {
    try {
      const { error } = await supabase
        .from("mRecomed")
        .delete()
        .eq("id_komik", comicId);

      if (error) throw error;

      // Refresh data
      fetchRecommendedComics();
      alert("Comic removed from recommended list.");
    } catch (error) {
      console.error("Error removing from recommended:", error);
      alert("Failed to remove comic from recommended list. Please try again.");
    }
  };

  // Handler untuk hapus dari popular
  const removeFromPopular = async (comicId: string) => {
    try {
      const { error } = await supabase
        .from("mPopular")
        .delete()
        .eq("id_komik", comicId)
        .eq("type", selectedPopularType);

      if (error) throw error;

      // Refresh data
      fetchPopularComics(selectedPopularType);
      alert(`Comic removed from ${selectedPopularType} popular list.`);
    } catch (error) {
      console.error("Error removing from popular:", error);
      alert("Failed to remove comic from popular list. Please try again.");
    }
  };

  // Handler untuk kembali ke halaman admin
  const navigateBack = () => {
    router.push(`/admin?view=comics-list`);
  };

  // Initial load
  useEffect(() => {
    if (activeTab === "recommended") {
      fetchRecommendedComics();
    } else {
      fetchPopularComics(selectedPopularType);
    }
    fetchAvailableComics();
  }, []);

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Featured Comics Management</h1>
          <p className="text-muted-foreground">
            Manage recommended and popular comics
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          <ChevronLeft className="h-4 w-4 mr-2" />
          Back to Admin
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Featured Comics</CardTitle>
          <CardDescription>
            Set comics to appear in recommended and popular sections on the home
            page
          </CardDescription>
        </CardHeader>

        <CardContent>
          <Tabs
            defaultValue="recommended"
            className="w-full"
            onValueChange={handleTabChange}
          >
            <TabsList className="grid grid-cols-2 mb-4">
              <TabsTrigger value="recommended" className="flex items-center">
                <Star className="h-4 w-4 mr-2" />
                Recommended Comics
              </TabsTrigger>
              <TabsTrigger value="popular" className="flex items-center">
                <ThumbsUp className="h-4 w-4 mr-2" />
                Popular Comics
              </TabsTrigger>
            </TabsList>

            {/* Tab Konten untuk Recommended Comics */}
            <TabsContent value="recommended" className="space-y-4">
              <div className="border rounded-md p-4">
                <h3 className="font-medium mb-2">Current Recommended Comics</h3>

                {isLoadingRecommended ? (
                  <div className="flex justify-center py-4">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                  </div>
                ) : recommendedComics.length === 0 ? (
                  <p className="text-muted-foreground">
                    No recommended comics yet.
                  </p>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
                    {recommendedComics.map((item) => (
                      <div
                        key={item.id_komik}
                        className="flex items-center border rounded-md p-2"
                      >
                        {item.comic?.cover_image_url && (
                          <img
                            src={item.comic.cover_image_url}
                            alt={item.comic?.title || "Comic cover"}
                            className="h-12 w-10 object-cover rounded mr-2"
                          />
                        )}
                        <div className="flex-grow">
                          <p className="font-medium truncate">
                            {item.comic?.title}
                          </p>
                          <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <span>Views: {item.comic?.view_count || 0}</span>
                            <span>•</span>
                            <span>Votes: {item.comic?.vote_count || 0}</span>
                          </div>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeFromRecommended(item.id_komik)}
                        >
                          <X className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="border rounded-md p-4">
                <div className="flex justify-between items-center mb-2">
                  <h3 className="font-medium">Add Comics to Recommended</h3>
                  <span className="text-xs text-muted-foreground">
                    Showing top 30 comics by votes
                  </span>
                </div>

                <div className="flex gap-2 mb-4">
                  <div className="flex-grow relative">
                    <Input
                      placeholder="Search comics..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                    />
                    <Search className="absolute right-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  </div>
                  <Button onClick={handleSearch}>Search</Button>
                </div>

                {isLoadingComics ? (
                  <div className="flex justify-center py-4">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                  </div>
                ) : availableComics.length === 0 ? (
                  <p className="text-muted-foreground">No comics found.</p>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
                    {availableComics.map((comic) => (
                      <div
                        key={comic.id}
                        className="flex items-center border rounded-md p-2"
                      >
                        {comic.cover_image_url && (
                          <img
                            src={comic.cover_image_url}
                            alt={comic.title}
                            className="h-12 w-10 object-cover rounded mr-2"
                          />
                        )}
                        <div className="flex-grow">
                          <p className="font-medium truncate">{comic.title}</p>
                          <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <span>Views: {comic.view_count || 0}</span>
                            <span>•</span>
                            <span>Votes: {comic.vote_count || 0}</span>
                          </div>
                        </div>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => addToRecommended(comic.id)}
                          disabled={recommendedComics.some(
                            (rc) => rc.id_komik === comic.id
                          )}
                        >
                          {recommendedComics.some(
                            (rc) => rc.id_komik === comic.id
                          )
                            ? "Added"
                            : "Add"}
                        </Button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </TabsContent>

            {/* Tab Konten untuk Popular Comics */}
            <TabsContent value="popular" className="space-y-4">
              <div className="mb-4">
                <label className="block text-sm font-medium mb-1">
                  Popular Type
                </label>
                <Select
                  value={selectedPopularType}
                  onValueChange={handlePopularTypeChange}
                >
                  <SelectTrigger className="w-[200px]">
                    <SelectValue placeholder="Select type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="harian">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-2" />
                        <span>Daily (Harian)</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="mingguan">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-2" />
                        <span>Weekly (Mingguan)</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="bulanan">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-2" />
                        <span>Monthly (Bulanan)</span>
                      </div>
                    </SelectItem>
                    <SelectItem value="all_time">
                      <div className="flex items-center">
                        <Clock className="h-4 w-4 mr-2" />
                        <span>All Time</span>
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="border rounded-md p-4">
                <h3 className="font-medium mb-2">
                  Current Popular Comics ({selectedPopularType})
                </h3>

                {isLoadingPopular ? (
                  <div className="flex justify-center py-4">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                  </div>
                ) : popularComics.length === 0 ? (
                  <p className="text-muted-foreground">
                    No popular comics for this category yet.
                  </p>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
                    {popularComics.map((item) => (
                      <div
                        key={`${item.id_komik}-${item.type}`}
                        className="flex items-center border rounded-md p-2"
                      >
                        {item.comic?.cover_image_url && (
                          <img
                            src={item.comic.cover_image_url}
                            alt={item.comic?.title || "Comic cover"}
                            className="h-12 w-10 object-cover rounded mr-2"
                          />
                        )}
                        <div className="flex-grow">
                          <p className="font-medium truncate">
                            {item.comic?.title}
                          </p>
                          <div className="flex flex-wrap items-center gap-2 text-xs">
                            <Badge variant="outline" className="text-xs">
                              {item.type}
                            </Badge>
                            <div className="flex items-center gap-1 text-muted-foreground">
                              <span>Views: {item.comic?.view_count || 0}</span>
                              <span>•</span>
                              <span>Votes: {item.comic?.vote_count || 0}</span>
                            </div>
                          </div>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeFromPopular(item.id_komik)}
                        >
                          <X className="h-4 w-4 text-destructive" />
                        </Button>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="border rounded-md p-4">
                <div className="flex justify-between items-center mb-2">
                  <h3 className="font-medium">
                    Add Comics to Popular ({selectedPopularType})
                  </h3>
                  <span className="text-xs text-muted-foreground">
                    Showing top 30 comics by votes
                  </span>
                </div>

                <div className="flex gap-2 mb-4">
                  <div className="flex-grow relative">
                    <Input
                      placeholder="Search comics..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                    />
                    <Search className="absolute right-2 top-2.5 h-4 w-4 text-muted-foreground" />
                  </div>
                  <Button onClick={handleSearch}>Search</Button>
                </div>

                {isLoadingComics ? (
                  <div className="flex justify-center py-4">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                  </div>
                ) : availableComics.length === 0 ? (
                  <p className="text-muted-foreground">No comics found.</p>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
                    {availableComics.map((comic) => (
                      <div
                        key={comic.id}
                        className="flex items-center border rounded-md p-2"
                      >
                        {comic.cover_image_url && (
                          <img
                            src={comic.cover_image_url}
                            alt={comic.title}
                            className="h-12 w-10 object-cover rounded mr-2"
                          />
                        )}
                        <div className="flex-grow">
                          <p className="font-medium truncate">{comic.title}</p>
                          <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <span>Views: {comic.view_count || 0}</span>
                            <span>•</span>
                            <span>Votes: {comic.vote_count || 0}</span>
                          </div>
                        </div>
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => addToPopular(comic.id)}
                          disabled={popularComics.some(
                            (pc) =>
                              pc.id_komik === comic.id &&
                              pc.type === selectedPopularType
                          )}
                        >
                          {popularComics.some(
                            (pc) =>
                              pc.id_komik === comic.id &&
                              pc.type === selectedPopularType
                          )
                            ? "Added"
                            : "Add"}
                        </Button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>

        <CardFooter className="flex justify-end">
          <Button variant="outline" onClick={navigateBack}>
            Done
          </Button>
        </CardFooter>
      </Card>
    </>
  );
}
