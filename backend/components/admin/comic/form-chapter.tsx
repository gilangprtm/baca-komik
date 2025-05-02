"use client";

import { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "@/lib/supabase/database.types";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { FileText, Loader2, Calendar } from "lucide-react";
import { Switch } from "@/components/ui/switch";

export default function ChapterFormContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const chapterId = searchParams.get("id");
  const comicId = searchParams.get("comicId");
  const comicTitle = searchParams.get("title");
  const isEditMode = !!chapterId;

  const [isLoading, setIsLoading] = useState(isEditMode);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isBulkMode, setIsBulkMode] = useState(false);
  const supabase = createClientComponentClient<Database>();
  const [nextChapterNumber, setNextChapterNumber] = useState<number | null>(
    null
  );

  const [formData, setFormData] = useState({
    chapter_number: "",
    thumbnail_image_url: "",
    release_date: new Date().toISOString().split("T")[0], // Default to today
  });

  const [bulkFormData, setBulkFormData] = useState({
    from_chapter: "",
    to_chapter: "",
    release_date: new Date().toISOString().split("T")[0], // Default to today
  });

  // Fetch chapter data if in edit mode, or get next chapter number if adding new chapter
  useEffect(() => {
    async function fetchData() {
      if (!comicId) {
        router.push("/admin?view=comics-list");
        return;
      }

      try {
        setIsLoading(true);

        if (isEditMode && chapterId) {
          // Fetch existing chapter data
          const { data, error } = await supabase
            .from("mChapter")
            .select("*")
            .eq("id", chapterId)
            .single();

          if (error) throw error;

          if (data) {
            setFormData({
              chapter_number: data.chapter_number.toString(),
              thumbnail_image_url: data.thumbnail_image_url || "",
              release_date: data.release_date
                ? new Date(data.release_date).toISOString().split("T")[0]
                : new Date().toISOString().split("T")[0],
            });
          }
        } else {
          // Get the next chapter number (highest chapter number + 1)
          const { data, error } = await supabase
            .from("mChapter")
            .select("chapter_number")
            .eq("id_komik", comicId)
            .order("chapter_number", { ascending: false })
            .limit(1);

          if (error) throw error;

          const nextNumber = data?.length > 0 ? data[0].chapter_number + 1 : 1;
          setNextChapterNumber(nextNumber);
          setFormData((prev) => ({
            ...prev,
            chapter_number: nextNumber.toString(),
          }));
          setBulkFormData((prev) => ({
            ...prev,
            from_chapter: nextNumber.toString(),
            to_chapter: (nextNumber + 4).toString(), // Default to 5 chapters
          }));
        }
      } catch (error) {
        console.error("Error fetching data:", error);
        alert("Failed to load data. Please try again.");
      } finally {
        setIsLoading(false);
      }
    }

    fetchData();
  }, [chapterId, comicId, isEditMode, router, supabase]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleBulkChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setBulkFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!comicId) {
      alert("Comic ID is missing. Please go back and try again.");
      return;
    }

    setIsSubmitting(true);

    try {
      if (isBulkMode && !isEditMode) {
        // Handle bulk add
        const fromChapter = parseFloat(bulkFormData.from_chapter);
        const toChapter = parseFloat(bulkFormData.to_chapter);

        if (isNaN(fromChapter) || isNaN(toChapter)) {
          throw new Error("Chapter numbers must be valid numbers");
        }

        if (fromChapter > toChapter) {
          throw new Error(
            "'From Chapter' must be less than or equal to 'To Chapter'"
          );
        }

        // Create array of chapters to insert
        const chaptersToInsert = [];
        for (let i = fromChapter; i <= toChapter; i += 1) {
          chaptersToInsert.push({
            id_komik: comicId,
            chapter_number: i,
            release_date: bulkFormData.release_date
              ? new Date(bulkFormData.release_date).toISOString()
              : null,
            created_date: new Date().toISOString(),
            view_count: 0,
            vote_count: 0,
            rating: 0,
          });
        }

        // Insert all chapters
        const { data, error } = await supabase
          .from("mChapter")
          .insert(chaptersToInsert)
          .select();

        if (error) throw error;
        console.log(
          `Successfully added ${chaptersToInsert.length} chapters:`,
          data
        );
      } else {
        // Handle single chapter add/edit
        // Prepare data for submission
        const chapterNumber = parseFloat(formData.chapter_number);

        if (isNaN(chapterNumber)) {
          throw new Error("Chapter number must be a valid number");
        }

        const submissionData = {
          id_komik: comicId,
          chapter_number: chapterNumber,
          thumbnail_image_url: formData.thumbnail_image_url,
          release_date: formData.release_date
            ? new Date(formData.release_date).toISOString()
            : null,
        };

        if (isEditMode) {
          // Update existing chapter
          const { error } = await supabase
            .from("mChapter")
            .update(submissionData)
            .eq("id", chapterId);

          if (error) throw error;
          console.log("Successfully updated chapter");
        } else {
          // Create new chapter
          const { data, error } = await supabase
            .from("mChapter")
            .insert([
              {
                ...submissionData,
                created_date: new Date().toISOString(),
                view_count: 0,
                vote_count: 0,
                rating: 0,
              },
            ])
            .select();

          if (error) throw error;
          console.log("Successfully added chapter:", data);
        }
      }

      // Navigate back to chapter list
      router.push(
        `/admin?view=chapters-list&comicId=${comicId}&title=${encodeURIComponent(
          comicTitle || ""
        )}`
      );
    } catch (error: any) {
      console.error(
        `Error ${isEditMode ? "updating" : "adding"} chapter(s):`,
        error
      );
      alert(
        `Failed to ${isEditMode ? "update" : "add"} chapter(s): ${
          error.message || "Unknown error"
        }`
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const navigateBack = () => {
    router.push(
      `/admin?view=chapters-list&comicId=${comicId}&title=${encodeURIComponent(
        comicTitle || ""
      )}`
    );
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="ml-2">Loading data...</span>
      </div>
    );
  }

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">
            {isEditMode ? "Edit Chapter" : "Add New Chapter"}
          </h1>
          <p className="text-muted-foreground">
            Comic: {comicTitle || "Unknown"}
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          Cancel
        </Button>
      </div>

      <Card>
        <form onSubmit={handleSubmit}>
          <CardHeader>
            <CardTitle className="flex justify-between items-center">
              <span>Chapter Information</span>
              {!isEditMode && (
                <div className="flex items-center space-x-2">
                  <Label htmlFor="bulk-mode" className="text-sm font-normal">
                    Single Chapter
                  </Label>
                  <Switch
                    id="bulk-mode"
                    checked={isBulkMode}
                    onCheckedChange={setIsBulkMode}
                  />
                  <Label htmlFor="bulk-mode" className="text-sm font-normal">
                    Bulk Add
                  </Label>
                </div>
              )}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {!isEditMode && isBulkMode ? (
              // Bulk Add Mode
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="from_chapter">From Chapter *</Label>
                    <Input
                      id="from_chapter"
                      name="from_chapter"
                      type="number"
                      step="1"
                      value={bulkFormData.from_chapter}
                      onChange={handleBulkChange}
                      placeholder={
                        nextChapterNumber ? nextChapterNumber.toString() : "1"
                      }
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="to_chapter">To Chapter *</Label>
                    <Input
                      id="to_chapter"
                      name="to_chapter"
                      type="number"
                      step="1"
                      value={bulkFormData.to_chapter}
                      onChange={handleBulkChange}
                      placeholder={
                        nextChapterNumber
                          ? (nextChapterNumber + 4).toString()
                          : "5"
                      }
                      required
                    />
                    <p className="text-xs text-muted-foreground">
                      Will create all chapters in this range
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="bulk_release_date">Release Date</Label>
                  <Input
                    id="bulk_release_date"
                    name="release_date"
                    type="date"
                    value={bulkFormData.release_date}
                    onChange={handleBulkChange}
                  />
                  <p className="text-xs text-muted-foreground">
                    All chapters will have the same release date
                  </p>
                </div>
              </div>
            ) : (
              // Single Chapter Mode
              <>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="chapter_number">Chapter Number *</Label>
                    <Input
                      id="chapter_number"
                      name="chapter_number"
                      type="number"
                      step="0.1"
                      value={formData.chapter_number}
                      onChange={handleChange}
                      placeholder={
                        nextChapterNumber ? nextChapterNumber.toString() : "1"
                      }
                      required
                    />
                    <p className="text-xs text-muted-foreground">
                      Use decimal numbers for extra chapters (e.g., 10.5)
                    </p>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="release_date">Release Date</Label>
                    <Input
                      id="release_date"
                      name="release_date"
                      type="date"
                      value={formData.release_date}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="thumbnail_image_url">
                    Thumbnail Image URL
                  </Label>
                  <Input
                    id="thumbnail_image_url"
                    name="thumbnail_image_url"
                    value={formData.thumbnail_image_url}
                    onChange={handleChange}
                    placeholder="https://example.com/thumbnail.jpg"
                  />
                  <p className="text-xs text-muted-foreground">
                    Leave empty to use the first page as thumbnail
                  </p>
                </div>
              </>
            )}
          </CardContent>
          <CardFooter className="flex justify-between">
            <Button variant="outline" type="button" onClick={navigateBack}>
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Saving...
                </>
              ) : (
                <>
                  <FileText className="mr-2 h-4 w-4" />
                  {isEditMode
                    ? "Update Chapter"
                    : isBulkMode
                    ? "Create Chapters"
                    : "Create Chapter"}
                </>
              )}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </>
  );
}
