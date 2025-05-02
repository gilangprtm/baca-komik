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
import { useRouter, useSearchParams } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import {
  Edit,
  Trash2,
  MoreHorizontal,
  ArrowUpDown,
  Eye,
  ChevronLeft,
  ChevronRight,
  FileText,
  Image,
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
import { formatDistanceToNow } from "date-fns";

type ChapterType = {
  id: string;
  id_komik: string;
  chapter_number: number;
  release_date: string | null;
  rating: number | null;
  view_count: number | null;
  vote_count: number | null;
  thumbnail_image_url: string | null;
  created_date: string | null;
  page_count?: number;
};

type SortColumn = keyof ChapterType | "page_count";

export default function ChaptersContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const comicId = searchParams.get("comicId");
  const comicTitle = searchParams.get("title");

  const [chapters, setChapters] = useState<ChapterType[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [sortColumn, setSortColumn] = useState<SortColumn>("chapter_number");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(10);
  const supabase = createClientComponentClient<Database>();

  useEffect(() => {
    if (!comicId) {
      router.push("/admin?view=comics-list");
      return;
    }

    async function fetchChapters() {
      setLoading(true);

      try {
        // Fetch chapters for the specific comic
        const { data: chaptersData, error: chaptersError } = await supabase
          .from("mChapter")
          .select("*")
          .eq("id_komik", comicId || "");

        if (chaptersError) {
          throw chaptersError;
        }

        // Fetch page counts for each chapter
        const chaptersWithPageCounts = await Promise.all(
          (chaptersData || []).map(async (chapter) => {
            const { count, error: pageError } = await supabase
              .from("trChapter")
              .select("*", { count: "exact", head: true })
              .eq("id_chapter", chapter.id);

            if (pageError) {
              console.error("Error fetching page count:", pageError);
              return { ...chapter, page_count: 0 };
            }

            return { ...chapter, page_count: count || 0 };
          })
        );

        setChapters(chaptersWithPageCounts);
      } catch (error) {
        console.error("Error fetching chapters:", error);
        setChapters([]);
      } finally {
        setLoading(false);
      }
    }

    fetchChapters();
  }, [supabase, comicId, router]);

  // Reset to first page when search query changes
  useEffect(() => {
    setCurrentPage(1);
  }, [searchQuery]);

  // Filter chapters based on search query
  const filteredChapters = useMemo(() => {
    return chapters.filter((chapter) =>
      chapter.chapter_number.toString().includes(searchQuery)
    );
  }, [chapters, searchQuery]);

  // Sort chapters based on sort column and direction
  const sortedChapters = useMemo(() => {
    return [...filteredChapters].sort((a, b) => {
      let aValue = a[sortColumn as keyof ChapterType];
      let bValue = b[sortColumn as keyof ChapterType];

      // Handle null values
      if (aValue === null)
        aValue =
          sortColumn === "view_count" ||
          sortColumn === "vote_count" ||
          sortColumn === "rating"
            ? 0
            : "";
      if (bValue === null)
        bValue =
          sortColumn === "view_count" ||
          sortColumn === "vote_count" ||
          sortColumn === "rating"
            ? 0
            : "";

      // Compare values
      if ((aValue ?? "") < (bValue ?? ""))
        return sortDirection === "asc" ? -1 : 1;
      if ((aValue ?? "") > (bValue ?? ""))
        return sortDirection === "asc" ? 1 : -1;
      return 0;
    });
  }, [filteredChapters, sortColumn, sortDirection]);

  // Get paginated chapters
  const paginatedChapters = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return sortedChapters.slice(startIndex, endIndex);
  }, [sortedChapters, currentPage, itemsPerPage]);

  // Calculate total pages
  const totalPages = Math.ceil(sortedChapters.length / itemsPerPage);

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

  // Format release date
  const formatDate = (dateString: string | null) => {
    if (!dateString) return "N/A";

    try {
      return formatDistanceToNow(new Date(dateString), { addSuffix: true });
    } catch (e) {
      return "Invalid date";
    }
  };

  // Handle SPA navigation
  const navigateToComics = () => {
    router.push("/admin?view=comics-list");
  };

  const navigateToAddChapter = () => {
    router.push(
      `/admin?view=chapter-form&comicId=${comicId}&title=${comicTitle}`
    );
  };

  const navigateToEditChapter = (id: string) => {
    router.push(
      `/admin?view=chapter-form&id=${id}&comicId=${comicId}&title=${comicTitle}`
    );
  };

  const navigateToPages = (chapterId: string, chapterNumber: number) => {
    router.push(
      `/admin?view=pages-list&chapterId=${chapterId}&chapterNumber=${chapterNumber}&comicId=${comicId}&title=${comicTitle}`
    );
  };

  const handleDeleteChapter = async (id: string) => {
    const confirmed = window.confirm(
      "Are you sure you want to delete this chapter?"
    );

    if (!confirmed) return;

    try {
      // First delete related pages
      const { error: pagesError } = await supabase
        .from("trChapter")
        .delete()
        .eq("id_chapter", id);

      if (pagesError) throw pagesError;

      // Then delete the chapter
      const { error } = await supabase.from("mChapter").delete().eq("id", id);

      if (error) throw error;

      // Update the chapters list
      setChapters(chapters.filter((chapter) => chapter.id !== id));
    } catch (error) {
      console.error("Error deleting chapter:", error);
      alert("Failed to delete chapter. Please try again.");
    }
  };

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Chapter Management</h1>
          <p className="text-muted-foreground">
            Comic: {comicTitle || "Unknown"}
          </p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline" onClick={navigateToComics}>
            Back to Comics
          </Button>
          <Button onClick={navigateToAddChapter}>
            <FileText className="mr-2 h-4 w-4" />
            Add New Chapter
          </Button>
        </div>
      </div>

      <div className="flex justify-between items-center mb-4">
        <Input
          placeholder="Search by chapter number..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="max-w-sm"
        />
        <div className="flex items-center gap-2">
          <span className="text-sm text-muted-foreground">Show:</span>
          <Select
            value={itemsPerPage.toString()}
            onValueChange={(value) => setItemsPerPage(Number(value))}
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

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="w-full h-16" />
          ))}
        </div>
      ) : (
        <>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead
                    className="cursor-pointer"
                    onClick={() => handleSort("chapter_number")}
                  >
                    Chapter Number
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead
                    className="cursor-pointer"
                    onClick={() => handleSort("release_date")}
                  >
                    Release Date
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead
                    className="cursor-pointer text-right"
                    onClick={() => handleSort("page_count")}
                  >
                    Pages
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead
                    className="cursor-pointer text-right"
                    onClick={() => handleSort("view_count")}
                  >
                    Views
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead
                    className="cursor-pointer text-right"
                    onClick={() => handleSort("vote_count")}
                  >
                    Votes
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead
                    className="cursor-pointer text-right"
                    onClick={() => handleSort("rating")}
                  >
                    Rating
                    <ArrowUpDown className="ml-2 h-4 w-4 inline" />
                  </TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {paginatedChapters.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={7}
                      className="h-24 text-center text-muted-foreground"
                    >
                      No chapters found.
                    </TableCell>
                  </TableRow>
                ) : (
                  paginatedChapters.map((chapter) => (
                    <TableRow key={chapter.id}>
                      <TableCell className="font-medium">
                        Chapter {chapter.chapter_number}
                      </TableCell>
                      <TableCell>{formatDate(chapter.release_date)}</TableCell>
                      <TableCell className="text-right">
                        {chapter.page_count || 0}
                      </TableCell>
                      <TableCell className="text-right">
                        {chapter.view_count || 0}
                      </TableCell>
                      <TableCell className="text-right">
                        {chapter.vote_count || 0}
                      </TableCell>
                      <TableCell className="text-right">
                        {chapter.rating ? chapter.rating.toFixed(1) : "N/A"}
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <span className="sr-only">Open menu</span>
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuLabel>Actions</DropdownMenuLabel>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              onClick={() =>
                                navigateToPages(
                                  chapter.id,
                                  chapter.chapter_number
                                )
                              }
                            >
                              <Image className="mr-2 h-4 w-4" />
                              Manage Pages
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => navigateToEditChapter(chapter.id)}
                            >
                              <Edit className="mr-2 h-4 w-4" />
                              Edit Chapter
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => handleDeleteChapter(chapter.id)}
                              className="text-destructive focus:text-destructive"
                            >
                              <Trash2 className="mr-2 h-4 w-4" />
                              Delete Chapter
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

          {totalPages > 1 && (
            <div className="flex justify-center mt-4 space-x-2">
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
              <span className="flex items-center px-2">
                Page {currentPage} of {totalPages}
              </span>
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
          )}
        </>
      )}
    </>
  );
}
