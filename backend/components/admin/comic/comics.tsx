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
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import Link from "next/link";
import { useEffect, useState, useMemo } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import {
  Edit,
  Trash2,
  MoreHorizontal,
  ArrowUpDown,
  Eye,
  BookOpen,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

type ComicType = {
  id: string;
  title: string;
  alternative_title: string | null;
  description: string | null;
  cover_image_url: string | null;
  country_id: string;
  release_year: number | null;
  view_count: number | null;
  bookmark_count: number | null;
  created_date: string | null;
  rank: number | null;
  chapter_count?: number;
};

type SortColumn = keyof ComicType | "chapter_count";

export default function ComicsContent() {
  const router = useRouter();
  const [comics, setComics] = useState<ComicType[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortColumn, setSortColumn] = useState<SortColumn>("title");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("asc");
  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const supabase = createClientComponentClient<Database>();

  useEffect(() => {
    async function fetchComics() {
      setLoading(true);

      try {
        // Fetch comics from the mKomik table
        const { data: comicsData, error: comicsError } = await supabase
          .from("mKomik")
          .select("*");

        if (comicsError) {
          throw comicsError;
        }

        // Fetch chapter counts for each comic
        const comicsWithChapterCounts = await Promise.all(
          (comicsData || []).map(async (comic) => {
            const { count, error: chapterError } = await supabase
              .from("mChapter")
              .select("*", { count: "exact", head: true })
              .eq("id_komik", comic.id);

            if (chapterError) {
              console.error("Error fetching chapter count:", chapterError);
              return { ...comic, chapter_count: 0 };
            }

            return { ...comic, chapter_count: count || 0 };
          })
        );

        setComics(comicsWithChapterCounts);
      } catch (error) {
        console.error("Error fetching comics:", error);
        setComics([]);
      } finally {
        setLoading(false);
      }
    }

    fetchComics();
  }, [supabase]);

  // Reset to first page when search query changes
  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery]);

  // Filter comics based on search query
  const filteredComics = useMemo(() => {
    return comics.filter(
      (comic) =>
        comic.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (comic.alternative_title &&
          comic.alternative_title
            .toLowerCase()
            .includes(searchQuery.toLowerCase()))
    );
  }, [comics, searchQuery]);

  // Sort comics based on sort column and direction
  const sortedComics = useMemo(() => {
    return [...filteredComics].sort((a, b) => {
      let aValue = a[sortColumn as keyof ComicType];
      let bValue = b[sortColumn as keyof ComicType];

      // Handle null values
      if (aValue === null)
        aValue =
          sortColumn === "view_count" || sortColumn === "bookmark_count"
            ? 0
            : "";
      if (bValue === null)
        bValue =
          sortColumn === "view_count" || sortColumn === "bookmark_count"
            ? 0
            : "";

      // Compare values
      if ((aValue ?? "") < (bValue ?? ""))
        return sortDirection === "asc" ? -1 : 1;
      if ((aValue ?? "") > (bValue ?? ""))
        return sortDirection === "asc" ? 1 : -1;
      return 0;
    });
  }, [filteredComics, sortColumn, sortDirection]);

  // Get paginated comics
  const paginatedComics = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return sortedComics.slice(startIndex, endIndex);
  }, [sortedComics, currentPage, itemsPerPage]);

  // Calculate total pages
  const totalPages = Math.ceil(sortedComics.length / itemsPerPage);

  // Handle page change
  const goToPage = (page: number) => {
    setCurrentPage(page);
  };

  // Handle sorting when a column header is clicked
  const handleSort = (column: SortColumn) => {
    if (sortColumn === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(column);
      setSortDirection("asc");
    }
  };

  // Format the country code
  const formatCountry = (code: string) => {
    switch (code) {
      case "KR":
        return "Korea";
      case "JPN":
        return "Japan";
      case "CN":
        return "China";
      default:
        return code;
    }
  };

  // Handle SPA navigation
  const navigateTo = (view: string) => {
    router.push(`/admin?view=${view}`);
  };

  const navigateToEdit = (id: string) => {
    router.push(`/admin?view=comics-form&id=${id}`);
  };

  const handleDeleteComic = async (id: string) => {
    const confirmed = window.confirm(
      "Are you sure you want to delete this comic?"
    );

    if (!confirmed) return;

    try {
      const { error } = await supabase.from("mKomik").delete().eq("id", id);

      if (error) throw error;

      // Update the comics list
      setComics(comics.filter((comic) => comic.id !== id));
    } catch (error) {
      console.error("Error deleting comic:", error);
      alert("Failed to delete comic. Please try again.");
    }
  };

  // Tambahkan fungsi navigasi ke chapter list
  const navigateToChapters = (id: string, title: string) => {
    router.push(
      `/admin?view=chapters-list&comicId=${id}&title=${encodeURIComponent(
        title
      )}`
    );
  };

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Comic Management</h1>
        <Button onClick={() => navigateTo("comics-form")}>
          <BookOpen className="mr-2 h-4 w-4" />
          Add New Comic
        </Button>
      </div>

      <div className="flex justify-between items-center mb-4">
        <Input
          placeholder="Search by title or alternative title..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
        <div className="flex items-center gap-2">
          <span className="text-sm text-muted-foreground">Show:</span>
          <Select
            value={itemsPerPage.toString()}
            onValueChange={(value) => {
              setItemsPerPage(parseInt(value));
              setCurrentPage(1); // Reset to first page when changing items per page
            }}
          >
            <SelectTrigger className="w-[70px]">
              <SelectValue placeholder="10" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="5">5</SelectItem>
              <SelectItem value="10">10</SelectItem>
              <SelectItem value="20">20</SelectItem>
              <SelectItem value="50">50</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("title")}
              >
                <div className="flex items-center">
                  Title
                  <ArrowUpDown className="ml-2 h-4 w-4" />
                  {sortColumn === "title" && (
                    <span className="ml-1">
                      {sortDirection === "asc" ? "↑" : "↓"}
                    </span>
                  )}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("country_id")}
              >
                <div className="flex items-center">
                  Country
                  <ArrowUpDown className="ml-2 h-4 w-4" />
                  {sortColumn === "country_id" && (
                    <span className="ml-1">
                      {sortDirection === "asc" ? "↑" : "↓"}
                    </span>
                  )}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("chapter_count")}
              >
                <div className="flex items-center">
                  Chapters
                  <ArrowUpDown className="ml-2 h-4 w-4" />
                  {sortColumn === "chapter_count" && (
                    <span className="ml-1">
                      {sortDirection === "asc" ? "↑" : "↓"}
                    </span>
                  )}
                </div>
              </TableHead>
              <TableHead
                className="cursor-pointer"
                onClick={() => handleSort("view_count")}
              >
                <div className="flex items-center">
                  Views
                  <ArrowUpDown className="ml-2 h-4 w-4" />
                  {sortColumn === "view_count" && (
                    <span className="ml-1">
                      {sortDirection === "asc" ? "↑" : "↓"}
                    </span>
                  )}
                </div>
              </TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              // Loading state - show skeletons
              Array(5)
                .fill(0)
                .map((_, index) => (
                  <TableRow key={`loading-${index}`}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Skeleton className="h-12 w-12 rounded" />
                        <div className="space-y-1">
                          <Skeleton className="h-4 w-[180px]" />
                          <Skeleton className="h-3 w-[120px]" />
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Skeleton className="h-4 w-[60px]" />
                    </TableCell>
                    <TableCell>
                      <Skeleton className="h-4 w-[40px]" />
                    </TableCell>
                    <TableCell>
                      <Skeleton className="h-4 w-[80px]" />
                    </TableCell>
                    <TableCell>
                      <Skeleton className="h-9 w-[90px]" />
                    </TableCell>
                  </TableRow>
                ))
            ) : paginatedComics.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="h-24 text-center">
                  No comics found
                </TableCell>
              </TableRow>
            ) : (
              paginatedComics.map((comic) => (
                <TableRow key={comic.id} className="group">
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-3">
                      {comic.cover_image_url ? (
                        <img
                          src={comic.cover_image_url}
                          alt={comic.title}
                          className="h-12 w-12 rounded object-cover"
                        />
                      ) : (
                        <div className="h-12 w-12 rounded bg-muted flex items-center justify-center">
                          <BookOpen className="h-6 w-6 text-muted-foreground" />
                        </div>
                      )}
                      <div>
                        <div className="font-medium">{comic.title}</div>
                        {comic.alternative_title && (
                          <div className="text-xs text-muted-foreground">
                            {comic.alternative_title}
                          </div>
                        )}
                      </div>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">
                      {formatCountry(comic.country_id)}
                    </Badge>
                  </TableCell>
                  <TableCell>{comic.chapter_count}</TableCell>
                  <TableCell>
                    <div className="flex items-center">
                      <Eye className="mr-1.5 h-4 w-4 text-muted-foreground" />
                      {(comic.view_count || 0).toLocaleString()}
                    </div>
                  </TableCell>
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <MoreHorizontal className="h-4 w-4" />
                          <span className="sr-only">Open menu</span>
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuLabel>Actions</DropdownMenuLabel>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem
                          onClick={() => navigateToEdit(comic.id)}
                        >
                          <Edit className="mr-2 h-4 w-4" />
                          Edit
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={() => handleDeleteComic(comic.id)}
                          className="text-destructive focus:text-destructive"
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Delete
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={() =>
                            navigateToChapters(comic.id, comic.title)
                          }
                        >
                          <BookOpen className="mr-2 h-4 w-4" />
                          Manage Chapters
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      {!loading && totalPages > 0 && (
        <div className="flex items-center justify-between space-x-2 py-4">
          <div className="text-sm text-muted-foreground">
            Showing {(currentPage - 1) * itemsPerPage + 1} to{" "}
            {Math.min(currentPage * itemsPerPage, sortedComics.length)} of{" "}
            {sortedComics.length} comics
          </div>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => goToPage(1)}
              disabled={currentPage === 1}
            >
              First
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => goToPage(currentPage - 1)}
              disabled={currentPage === 1}
            >
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <div className="flex items-center gap-1">
              {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
                // Show at most 5 page buttons
                let pageNum = currentPage;

                // Adjust which page numbers to show based on current page
                if (currentPage <= 3) {
                  pageNum = i + 1;
                } else if (currentPage >= totalPages - 2) {
                  pageNum = totalPages - 4 + i;
                } else {
                  pageNum = currentPage - 2 + i;
                }

                // Skip if page number exceeds total pages or is less than 1
                if (pageNum > totalPages || pageNum < 1) {
                  return null;
                }

                return (
                  <Button
                    key={pageNum}
                    variant={currentPage === pageNum ? "default" : "outline"}
                    size="sm"
                    onClick={() => goToPage(pageNum)}
                    className="w-9"
                  >
                    {pageNum}
                  </Button>
                );
              })}
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => goToPage(currentPage + 1)}
              disabled={currentPage === totalPages}
            >
              <ChevronRight className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => goToPage(totalPages)}
              disabled={currentPage === totalPages}
            >
              Last
            </Button>
          </div>
        </div>
      )}
    </>
  );
}
