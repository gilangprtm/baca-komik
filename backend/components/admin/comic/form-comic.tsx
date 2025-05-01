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
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { BookOpen, Loader2 } from "lucide-react";

export default function ComicFormContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const comicId = searchParams.get("id");
  const isEditMode = !!comicId;

  const [isLoading, setIsLoading] = useState(isEditMode);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const supabase = createClientComponentClient<Database>();

  const [formData, setFormData] = useState({
    title: "",
    alternative_title: "",
    description: "",
    country_id: "JPN" as "JPN" | "KR" | "CN", // Default to Japan
    cover_image_url: "",
    release_year: "",
    status: "On Going" as "On Going" | "End" | "Hiatus" | "Break", // Default status
  });

  // Fetch comic data if in edit mode
  useEffect(() => {
    async function fetchComicData() {
      if (!comicId) return;

      try {
        setIsLoading(true);
        const { data, error } = await supabase
          .from("mKomik")
          .select("*")
          .eq("id", comicId)
          .single();

        if (error) throw error;

        if (data) {
          setFormData({
            title: data.title || "",
            alternative_title: data.alternative_title || "",
            description: data.description || "",
            country_id: data.country_id,
            cover_image_url: data.cover_image_url || "",
            release_year: data.release_year ? data.release_year.toString() : "",
            status: data.status || "On Going",
          });
        }
      } catch (error) {
        console.error("Error fetching comic data:", error);
        alert("Failed to load comic data. Please try again.");
      } finally {
        setIsLoading(false);
      }
    }

    if (isEditMode) {
      fetchComicData();
    }
  }, [comicId, isEditMode, supabase]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSelectChange = (name: string, value: string) => {
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    try {
      // Prepare data for submission
      const submissionData = {
        ...formData,
        release_year: formData.release_year
          ? parseInt(formData.release_year)
          : null,
      };

      if (isEditMode) {
        // Update existing comic
        const { error } = await supabase
          .from("mKomik")
          .update(submissionData)
          .eq("id", comicId);

        if (error) throw error;
        console.log("Successfully updated comic");
      } else {
        // Create new comic
        const { data, error } = await supabase
          .from("mKomik")
          .insert([
            {
              ...submissionData,
              created_date: new Date().toISOString(),
            },
          ])
          .select();

        if (error) throw error;
        console.log("Successfully added comic:", data);
      }

      // Redirect to comics list after successful submission
      router.push("/admin?view=comics-list");
    } catch (error) {
      console.error(
        `Error ${isEditMode ? "updating" : "adding"} comic:`,
        error
      );
      alert(
        `Failed to ${isEditMode ? "update" : "add"} comic. Please try again.`
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const navigateToComics = () => {
    router.push("/admin?view=comics-list");
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="ml-2">Loading comic data...</span>
      </div>
    );
  }

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">
          {isEditMode ? "Edit Comic" : "Add New Comic"}
        </h1>
        <Button variant="outline" onClick={navigateToComics}>
          Cancel
        </Button>
      </div>

      <Card>
        <form onSubmit={handleSubmit}>
          <CardHeader>
            <CardTitle>Comic Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="title">Title *</Label>
                <Input
                  id="title"
                  name="title"
                  value={formData.title}
                  onChange={handleChange}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="alternative_title">Alternative Title</Label>
                <Input
                  id="alternative_title"
                  name="alternative_title"
                  value={formData.alternative_title}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                name="description"
                rows={5}
                value={formData.description}
                onChange={handleChange}
              />
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="country_id">Country of Origin</Label>
                <Select
                  value={formData.country_id}
                  onValueChange={(value) =>
                    handleSelectChange("country_id", value)
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select country" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="JPN">Japan (Manga)</SelectItem>
                    <SelectItem value="KR">Korea (Manhwa)</SelectItem>
                    <SelectItem value="CN">China (Manhua)</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="status">Status</Label>
                <Select
                  value={formData.status}
                  onValueChange={(value) => handleSelectChange("status", value)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select status" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="On Going">On Going</SelectItem>
                    <SelectItem value="End">End</SelectItem>
                    <SelectItem value="Hiatus">Hiatus</SelectItem>
                    <SelectItem value="Break">Break</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label htmlFor="release_year">Release Year</Label>
                <Input
                  id="release_year"
                  name="release_year"
                  type="number"
                  value={formData.release_year}
                  onChange={handleChange}
                  min="1900"
                  max={new Date().getFullYear()}
                />
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="cover_image_url">Cover Image URL</Label>
              <Input
                id="cover_image_url"
                name="cover_image_url"
                value={formData.cover_image_url}
                onChange={handleChange}
                placeholder="https://example.com/image.jpg"
              />
              {formData.cover_image_url && (
                <div className="mt-2 border rounded-md p-2 flex items-center">
                  <div className="w-20 h-28 bg-muted rounded-md overflow-hidden mr-4">
                    <img
                      src={formData.cover_image_url}
                      alt="Cover preview"
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src = "";
                        (e.target as HTMLImageElement).classList.add(
                          "bg-muted",
                          "flex",
                          "items-center",
                          "justify-center"
                        );
                        const parent = (e.target as HTMLImageElement)
                          .parentElement;
                        if (parent) {
                          const icon = document.createElement("div");
                          icon.className =
                            "absolute inset-0 flex items-center justify-center";
                          const svg = document.createElement("div");
                          svg.innerHTML =
                            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>';
                          icon.appendChild(svg);
                          parent.appendChild(icon);
                        }
                      }}
                    />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Cover Preview</p>
                    <p className="text-xs text-muted-foreground">
                      URL will be validated upon submission
                    </p>
                  </div>
                </div>
              )}
            </div>
          </CardContent>
          <CardFooter className="flex justify-end space-x-2 mt-4">
            <Button variant="outline" type="button" onClick={navigateToComics}>
              Cancel
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {isEditMode ? "Updating..." : "Saving..."}
                </>
              ) : isEditMode ? (
                "Update Comic"
              ) : (
                "Save Comic"
              )}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </>
  );
}
