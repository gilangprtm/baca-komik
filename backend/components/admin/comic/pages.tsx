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
import { useEffect, useState, useRef } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter, useSearchParams } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import {
  Edit,
  Trash2,
  MoreHorizontal,
  ArrowUpDown,
  Plus,
  ChevronLeft,
  ChevronRight,
  Image,
  Loader2,
  ArrowUp,
  ArrowDown,
  Eye,
  ImagePlus,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Label } from "@/components/ui/label";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

type PageType = {
  id_chapter: string;
  page_number: number;
  page_url: string;
};

export default function PagesContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const chapterId = searchParams.get("chapterId");
  const chapterNumber = searchParams.get("chapterNumber");
  const comicId = searchParams.get("comicId");
  const comicTitle = searchParams.get("title");

  const [pages, setPages] = useState<PageType[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // Form state for adding new page
  const [newPageUrl, setNewPageUrl] = useState("");
  const [bulkPageUrls, setBulkPageUrls] = useState("");
  const [showBulkAdd, setShowBulkAdd] = useState(false);

  // Tambahkan state untuk base URL dan total pages
  const [showSmartBulk, setShowSmartBulk] = useState(false);
  const [baseUrl, setBaseUrl] = useState("");
  const [startPage, setStartPage] = useState<number>(1);
  const [endPage, setEndPage] = useState<number>(10);
  const [fileExtension, setFileExtension] = useState<string>("webp");

  const supabase = createClientComponentClient<Database>();

  // Fetch pages for the chapter
  useEffect(() => {
    if (!chapterId) {
      router.push(
        `/admin?view=chapters-list&comicId=${
          comicId || ""
        }&title=${encodeURIComponent(comicTitle || "")}`
      );
      return;
    }

    async function fetchPages() {
      setLoading(true);

      try {
        const { data, error } = await supabase
          .from("trChapter")
          .select("*")
          .eq("id_chapter", chapterId as string)
          .order("page_number", { ascending: true });

        if (error) throw error;

        setPages(data || []);
      } catch (error) {
        console.error("Error fetching pages:", error);
        setPages([]);
      } finally {
        setLoading(false);
      }
    }

    fetchPages();
  }, [chapterId, comicId, comicTitle, router, supabase]);

  const navigateBack = () => {
    router.push(
      `/admin?view=chapters-list&comicId=${
        comicId || ""
      }&title=${encodeURIComponent(comicTitle || "")}`
    );
  };

  const handleDeletePage = async (pageNumber: number) => {
    if (!chapterId) return;

    const confirmed = window.confirm(
      "Are you sure you want to delete this page?"
    );

    if (!confirmed) return;

    try {
      // Delete the page
      const { error } = await supabase
        .from("trChapter")
        .delete()
        .eq("id_chapter", chapterId)
        .eq("page_number", pageNumber);

      if (error) throw error;

      // Update page numbers for all pages after the deleted one
      const pagesAfter = pages.filter((p) => p.page_number > pageNumber);

      for (const page of pagesAfter) {
        const { error: updateError } = await supabase
          .from("trChapter")
          .update({ page_number: page.page_number - 1 })
          .eq("id_chapter", chapterId)
          .eq("page_number", page.page_number);

        if (updateError) throw updateError;
      }

      // Update the local pages state
      setPages((prevPages) => {
        const newPages = prevPages.filter((p) => p.page_number !== pageNumber);
        return newPages.map((p) =>
          p.page_number > pageNumber
            ? { ...p, page_number: p.page_number - 1 }
            : p
        );
      });
    } catch (error) {
      console.error("Error deleting page:", error);
      alert("Failed to delete page. Please try again.");
    }
  };

  const handleUpdatePageUrl = async (pageNumber: number, newUrl: string) => {
    if (!chapterId) return;

    try {
      const { error } = await supabase
        .from("trChapter")
        .update({ page_url: newUrl })
        .eq("id_chapter", chapterId)
        .eq("page_number", pageNumber);

      if (error) throw error;

      // Update local state
      setPages((prevPages) =>
        prevPages.map((p) =>
          p.page_number === pageNumber ? { ...p, page_url: newUrl } : p
        )
      );
    } catch (error) {
      console.error("Error updating page URL:", error);
      alert("Failed to update page URL. Please try again.");
    }
  };

  const handleMovePage = async (
    pageNumber: number,
    direction: "up" | "down"
  ) => {
    if (!chapterId) return;

    // Find the target page and the page to swap with
    const targetPage = pages.find((p) => p.page_number === pageNumber);
    const swapWithPage = pages.find(
      (p) =>
        p.page_number === (direction === "up" ? pageNumber - 1 : pageNumber + 1)
    );

    if (!targetPage || !swapWithPage) return;

    try {
      // Update the first page's number to a temporary value to avoid unique constraint violations
      const tempPageNumber = -999;

      // First update target page to temp number
      const { error: error1 } = await supabase
        .from("trChapter")
        .update({ page_number: tempPageNumber })
        .eq("id_chapter", chapterId)
        .eq("page_number", targetPage.page_number);

      if (error1) throw error1;

      // Then update the other page to target's original number
      const { error: error2 } = await supabase
        .from("trChapter")
        .update({ page_number: targetPage.page_number })
        .eq("id_chapter", chapterId)
        .eq("page_number", swapWithPage.page_number);

      if (error2) throw error2;

      // Finally update the target page to the other page's original number
      const { error: error3 } = await supabase
        .from("trChapter")
        .update({ page_number: swapWithPage.page_number })
        .eq("id_chapter", chapterId)
        .eq("page_number", tempPageNumber);

      if (error3) throw error3;

      // Update local state
      setPages((prevPages) => {
        const newPages = [...prevPages];
        const targetIndex = newPages.findIndex(
          (p) => p.page_number === pageNumber
        );
        const swapIndex = newPages.findIndex(
          (p) =>
            p.page_number ===
            (direction === "up" ? pageNumber - 1 : pageNumber + 1)
        );

        if (targetIndex !== -1 && swapIndex !== -1) {
          // Swap page numbers
          const tempNumber = newPages[targetIndex].page_number;
          newPages[targetIndex].page_number = newPages[swapIndex].page_number;
          newPages[swapIndex].page_number = tempNumber;
        }

        return newPages.sort((a, b) => a.page_number - b.page_number);
      });
    } catch (error) {
      console.error("Error moving page:", error);
      alert("Failed to reorder pages. Please try again.");
    }
  };

  const handleAddPage = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!newPageUrl) {
      alert("Please enter a page URL");
      return;
    }

    if (!chapterId) {
      alert("Chapter ID is missing");
      return;
    }

    setSubmitting(true);

    try {
      // Get the highest page number and add 1
      const newPageNumber =
        pages.length > 0 ? Math.max(...pages.map((p) => p.page_number)) + 1 : 1;

      const { error } = await supabase.from("trChapter").insert({
        id_chapter: chapterId as string,
        page_number: newPageNumber,
        page_url: newPageUrl,
      });

      if (error) throw error;

      // Add to local state
      setPages([
        ...pages,
        {
          id_chapter: chapterId as string,
          page_number: newPageNumber,
          page_url: newPageUrl,
        },
      ]);

      // Clear input
      setNewPageUrl("");
    } catch (error) {
      console.error("Error adding page:", error);
      alert("Failed to add page. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleAddBulkPages = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!bulkPageUrls.trim()) {
      alert("Please enter page URLs");
      return;
    }

    if (!chapterId) {
      alert("Chapter ID is missing");
      return;
    }

    setSubmitting(true);

    try {
      // Split by newlines and filter empty lines
      const urls = bulkPageUrls
        .split("\n")
        .map((url) => url.trim())
        .filter((url) => url);

      if (urls.length === 0) {
        alert("No valid URLs found");
        return;
      }

      // Get the highest page number and add from there
      let startPageNumber =
        pages.length > 0 ? Math.max(...pages.map((p) => p.page_number)) + 1 : 1;

      // Prepare data for insertion
      const newPages = urls.map((url, index) => ({
        id_chapter: chapterId as string,
        page_number: startPageNumber + index,
        page_url: url,
      }));

      // Insert all pages
      const { error } = await supabase.from("trChapter").insert(newPages);

      if (error) throw error;

      // Add to local state
      setPages([...pages, ...newPages]);

      // Clear input
      setBulkPageUrls("");
      setShowBulkAdd(false);
    } catch (error) {
      console.error("Error adding bulk pages:", error);
      alert("Failed to add pages. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  // Tambahkan fungsi untuk membuat URL berdasarkan pola
  const generateUrlsFromPattern = (
    baseUrl: string,
    start: number,
    end: number,
    extension: string
  ): string[] => {
    // Hapus angka dan ekstensi di akhir URL jika ada
    const cleanBaseUrl = baseUrl.replace(/\/\d+\.\w+$/, "");
    // Pastikan URL diakhiri dengan "/"
    const normalizedBaseUrl = cleanBaseUrl.endsWith("/")
      ? cleanBaseUrl
      : `${cleanBaseUrl}/`;

    // Buat array URL berdasarkan range
    const urls: string[] = [];
    for (let i = start; i <= end; i++) {
      urls.push(`${normalizedBaseUrl}${i}.${extension}`);
    }
    return urls;
  };

  // Tambahkan fungsi untuk menangani smart bulk upload
  const handleSmartBulkAdd = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!baseUrl) {
      alert("Please enter a base URL");
      return;
    }

    if (!chapterId) {
      alert("Chapter ID is missing");
      return;
    }

    if (startPage > endPage) {
      alert("Start page cannot be greater than end page");
      return;
    }

    setSubmitting(true);

    try {
      // Generate URLs berdasarkan range
      const urls = generateUrlsFromPattern(
        baseUrl,
        startPage,
        endPage,
        fileExtension
      );

      // Get the highest page number and add from there
      let currentMaxPageNumber =
        pages.length > 0 ? Math.max(...pages.map((p) => p.page_number)) : 0;

      // Prepare data for insertion
      const newPages = urls.map((url, index) => ({
        id_chapter: chapterId as string,
        page_number: currentMaxPageNumber + index + 1,
        page_url: url,
      }));

      // Insert all pages
      const { error } = await supabase.from("trChapter").insert(newPages);

      if (error) throw error;

      // Add to local state
      setPages([...pages, ...newPages]);

      // Clear input and reset state
      setBaseUrl("");
      setShowSmartBulk(false);
      setShowBulkAdd(false);
    } catch (error) {
      console.error("Error adding bulk pages:", error);
      alert("Failed to add pages. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Page Management</h1>
          <p className="text-muted-foreground">
            Comic: {comicTitle || "Unknown"} | Chapter{" "}
            {chapterNumber || "Unknown"}
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          Back to Chapters
        </Button>
      </div>

      {/* Add new page form */}
      <Card className="mb-6">
        <CardHeader>
          <CardTitle>Add Pages</CardTitle>
          <CardDescription>Add new pages to this chapter</CardDescription>
        </CardHeader>
        <CardContent>
          {!showBulkAdd ? (
            <form onSubmit={handleAddPage} className="flex space-x-2">
              <div className="flex-1">
                <Label htmlFor="page_url" className="sr-only">
                  Page URL
                </Label>
                <Input
                  id="page_url"
                  placeholder="Enter page image URL"
                  value={newPageUrl}
                  onChange={(e) => setNewPageUrl(e.target.value)}
                  disabled={submitting}
                />
              </div>
              <Button type="submit" disabled={submitting}>
                {submitting ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Plus className="h-4 w-4 mr-2" />
                )}
                Add Page
              </Button>
              <Button
                type="button"
                variant="secondary"
                onClick={() => setShowBulkAdd(true)}
                disabled={submitting}
              >
                <ImagePlus className="h-4 w-4 mr-2" />
                Bulk Add
              </Button>
            </form>
          ) : (
            <div>
              <div className="flex space-x-2 mb-3">
                <Button
                  type="button"
                  variant={!showSmartBulk ? "default" : "outline"}
                  onClick={() => setShowSmartBulk(false)}
                  size="sm"
                >
                  Manual Bulk
                </Button>
                <Button
                  type="button"
                  variant={showSmartBulk ? "default" : "outline"}
                  onClick={() => setShowSmartBulk(true)}
                  size="sm"
                >
                  Smart Pattern
                </Button>
              </div>

              {!showSmartBulk ? (
                // Form bulk upload manual original
                <form onSubmit={handleAddBulkPages}>
                  <Label htmlFor="bulk_urls">Page URLs (one per line)</Label>
                  <textarea
                    id="bulk_urls"
                    className="w-full min-h-[100px] p-2 border rounded-md mt-1 mb-2"
                    placeholder="https://example.com/page1.jpg&#10;https://example.com/page2.jpg&#10;https://example.com/page3.jpg"
                    value={bulkPageUrls}
                    onChange={(e) => setBulkPageUrls(e.target.value)}
                    disabled={submitting}
                  />
                  <div className="flex space-x-2 mt-2">
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => setShowBulkAdd(false)}
                      disabled={submitting}
                    >
                      Cancel
                    </Button>
                    <Button type="submit" disabled={submitting}>
                      {submitting ? (
                        <Loader2 className="h-4 w-4 animate-spin mr-2" />
                      ) : (
                        <Plus className="h-4 w-4 mr-2" />
                      )}
                      Add Pages
                    </Button>
                  </div>
                </form>
              ) : (
                // Form smart pattern bulk upload
                <form onSubmit={handleSmartBulkAdd}>
                  <div className="space-y-4">
                    <div>
                      <Label htmlFor="base_url">Base URL Pattern</Label>
                      <Input
                        id="base_url"
                        placeholder="https://github.com/example/comic/ch1/"
                        value={baseUrl}
                        onChange={(e) => setBaseUrl(e.target.value)}
                        disabled={submitting}
                        className="mt-1"
                      />
                      <p className="text-xs text-muted-foreground mt-1">
                        Enter the URL pattern. System will automatically add
                        1.webp, 2.webp, etc.
                      </p>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="file_extension">File Extension</Label>
                        <Select
                          value={fileExtension}
                          onValueChange={setFileExtension}
                          disabled={submitting}
                        >
                          <SelectTrigger className="mt-1">
                            <SelectValue placeholder="File Extension" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="webp">webp</SelectItem>
                            <SelectItem value="jpg">jpg</SelectItem>
                            <SelectItem value="jpeg">jpeg</SelectItem>
                            <SelectItem value="png">png</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4 mt-3">
                      <div>
                        <Label htmlFor="start_page">From Page</Label>
                        <Input
                          id="start_page"
                          type="number"
                          min="1"
                          max="999"
                          value={startPage}
                          onChange={(e) =>
                            setStartPage(parseInt(e.target.value) || 1)
                          }
                          disabled={submitting}
                          className="mt-1"
                        />
                      </div>

                      <div>
                        <Label htmlFor="end_page">To Page</Label>
                        <Input
                          id="end_page"
                          type="number"
                          min="1"
                          max="999"
                          value={endPage}
                          onChange={(e) =>
                            setEndPage(parseInt(e.target.value) || startPage)
                          }
                          disabled={submitting}
                          className="mt-1"
                        />
                      </div>
                    </div>

                    <div className="mt-2">
                      <p className="text-sm font-medium">
                        Preview{" "}
                        {startPage === endPage
                          ? "URL"
                          : `URLs (${endPage - startPage + 1} pages)`}
                        :
                      </p>
                      <div className="text-xs text-muted-foreground space-y-1 mt-1 p-2 bg-muted rounded-md max-w-full overflow-auto">
                        {baseUrl &&
                          generateUrlsFromPattern(
                            baseUrl,
                            startPage,
                            Math.min(startPage + 2, endPage),
                            fileExtension
                          ).map((url, i) => (
                            <div key={i} className="truncate">
                              {startPage + i}. {url}
                            </div>
                          ))}
                        {baseUrl && endPage > startPage + 3 && (
                          <div className="text-center">
                            ... and {endPage - startPage - 2} more
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="flex space-x-2 mt-4">
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => setShowBulkAdd(false)}
                      disabled={submitting}
                    >
                      Cancel
                    </Button>
                    <Button type="submit" disabled={submitting}>
                      {submitting ? (
                        <Loader2 className="h-4 w-4 animate-spin mr-2" />
                      ) : (
                        <Plus className="h-4 w-4 mr-2" />
                      )}
                      Add {endPage - startPage + 1} Pages
                    </Button>
                  </div>
                </form>
              )}
            </div>
          )}
        </CardContent>
      </Card>

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="w-full h-16" />
          ))}
        </div>
      ) : (
        <>
          <div className="rounded-md border mb-4">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Page #</TableHead>
                  <TableHead>Preview</TableHead>
                  <TableHead>URL</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {pages.length === 0 ? (
                  <TableRow>
                    <TableCell
                      colSpan={4}
                      className="h-24 text-center text-muted-foreground"
                    >
                      No pages found. Add pages using the form above.
                    </TableCell>
                  </TableRow>
                ) : (
                  pages.map((page) => (
                    <TableRow key={page.page_number}>
                      <TableCell className="font-medium">
                        {page.page_number}
                      </TableCell>
                      <TableCell>
                        <div className="relative w-16 h-16 overflow-hidden rounded border">
                          <img
                            src={page.page_url}
                            alt={`Page ${page.page_number}`}
                            className="object-cover w-full h-full"
                            onError={(e) => {
                              (e.target as HTMLImageElement).src =
                                "https://placehold.co/200x300/png?text=Error";
                            }}
                          />
                        </div>
                      </TableCell>
                      <TableCell className="max-w-md truncate">
                        <div className="flex items-center space-x-2">
                          <Input
                            value={page.page_url}
                            onChange={(e) => {
                              // Update only in local state first
                              setPages((prevPages) =>
                                prevPages.map((p) =>
                                  p.page_number === page.page_number
                                    ? { ...p, page_url: e.target.value }
                                    : p
                                )
                              );
                            }}
                            onBlur={(e) => {
                              // Update in database on blur if changed
                              if (e.target.value !== page.page_url) {
                                handleUpdatePageUrl(
                                  page.page_number,
                                  e.target.value
                                );
                              }
                            }}
                          />
                          <a
                            href={page.page_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex-shrink-0"
                          >
                            <Button variant="ghost" size="sm">
                              <Eye className="h-4 w-4" />
                            </Button>
                          </a>
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end space-x-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            disabled={page.page_number === 1}
                            onClick={() =>
                              handleMovePage(page.page_number, "up")
                            }
                          >
                            <ArrowUp className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            disabled={page.page_number === pages.length}
                            onClick={() =>
                              handleMovePage(page.page_number, "down")
                            }
                          >
                            <ArrowDown className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-destructive"
                            onClick={() => handleDeletePage(page.page_number)}
                          >
                            <Trash2 className="h-4 w-4" />
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
      )}
    </>
  );
}
