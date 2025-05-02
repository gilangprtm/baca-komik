"use client";

import { useState, useEffect, useMemo } from "react";
import { useRouter, useSearchParams } from "next/navigation";
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
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  ChevronLeft,
  PlusCircle,
  X,
  Tag,
  Loader2,
  BookOpen,
  Users,
  Brush,
  FileText,
} from "lucide-react";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
import { CheckedState } from "@radix-ui/react-checkbox";

type Author = {
  id: string;
  name: string;
};

type Artist = {
  id: string;
  name: string;
};

type Genre = {
  id: string;
  name: string;
};

type Format = {
  id: string;
  name: string;
};

export default function MetadataContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const comicId = searchParams.get("comicId");
  const comicTitle = searchParams.get("title");

  // States for loading
  const [isLoading, setIsLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  // States for selections
  const [selectedAuthors, setSelectedAuthors] = useState<string[]>([]);
  const [selectedArtists, setSelectedArtists] = useState<string[]>([]);
  const [selectedGenres, setSelectedGenres] = useState<string[]>([]);
  const [selectedFormats, setSelectedFormats] = useState<string[]>([]);

  // States for available options
  const [authors, setAuthors] = useState<Author[]>([]);
  const [artists, setArtists] = useState<Artist[]>([]);
  const [genres, setGenres] = useState<Genre[]>([]);
  const [formats, setFormats] = useState<Format[]>([]);

  // States for adding new options
  const [newAuthorName, setNewAuthorName] = useState("");
  const [newArtistName, setNewArtistName] = useState("");
  const [newGenreName, setNewGenreName] = useState("");
  const [newFormatName, setNewFormatName] = useState("");

  // Tambahkan state untuk query pencarian
  const [authorSearchQuery, setAuthorSearchQuery] = useState("");
  const [artistSearchQuery, setArtistSearchQuery] = useState("");
  const [genreSearchQuery, setGenreSearchQuery] = useState("");
  const [formatSearchQuery, setFormatSearchQuery] = useState("");

  const supabase = createClientComponentClient<Database>();

  useEffect(() => {
    if (!comicId) {
      router.push("/admin?view=comics-list");
      return;
    }

    // Fetch all metadata-related data
    async function fetchData() {
      setIsLoading(true);
      try {
        // Fetch Authors
        const { data: allAuthors, error: authorsError } = await supabase
          .from("mAuthor")
          .select("*")
          .order("name");

        if (authorsError) throw authorsError;
        setAuthors(allAuthors || []);

        // Fetch Artists
        const { data: allArtists, error: artistsError } = await supabase
          .from("mArtist")
          .select("*")
          .order("name");

        if (artistsError) throw artistsError;
        setArtists(allArtists || []);

        // Fetch Genres
        const { data: allGenres, error: genresError } = await supabase
          .from("mGenre")
          .select("*")
          .order("name");

        if (genresError) throw genresError;
        setGenres(allGenres || []);

        // Fetch Formats
        const { data: allFormats, error: formatsError } = await supabase
          .from("mFormat")
          .select("*")
          .order("name");

        if (formatsError) throw formatsError;
        setFormats(allFormats || []);

        // Fetch comic's selected authors
        const { data: comicAuthors, error: comicAuthorsError } = await supabase
          .from("trAuthor")
          .select("id_author")
          .eq("id_komik", comicId as string);

        if (comicAuthorsError) throw comicAuthorsError;
        setSelectedAuthors(comicAuthors.map((item) => item.id_author) || []);

        // Fetch comic's selected artists
        const { data: comicArtists, error: comicArtistsError } = await supabase
          .from("trArtist")
          .select("id_artist")
          .eq("id_komik", comicId as string);

        if (comicArtistsError) throw comicArtistsError;
        setSelectedArtists(comicArtists.map((item) => item.id_artist) || []);

        // Fetch comic's selected genres
        const { data: comicGenres, error: comicGenresError } = await supabase
          .from("trGenre")
          .select("id_genre")
          .eq("id_komik", comicId as string);

        if (comicGenresError) throw comicGenresError;
        setSelectedGenres(comicGenres.map((item) => item.id_genre) || []);

        // Fetch comic's selected formats
        const { data: comicFormats, error: comicFormatsError } = await supabase
          .from("trFormat")
          .select("id_format")
          .eq("id_komik", comicId as string);

        if (comicFormatsError) throw comicFormatsError;
        setSelectedFormats(comicFormats.map((item) => item.id_format) || []);
      } catch (error) {
        console.error("Error fetching metadata:", error);
        alert("Failed to load metadata. Please try again.");
      } finally {
        setIsLoading(false);
      }
    }

    fetchData();
  }, [comicId, router, supabase]);

  const handleSaveMetadata = async () => {
    if (!comicId) return;

    setSubmitting(true);

    try {
      // Update Authors
      // First delete all existing authors for this comic
      await supabase.from("trAuthor").delete().eq("id_komik", comicId);

      // Then insert the selected authors
      if (selectedAuthors.length > 0) {
        const authorInserts = selectedAuthors.map((authorId) => ({
          id_komik: comicId,
          id_author: authorId,
        }));

        const { error: authorsInsertError } = await supabase
          .from("trAuthor")
          .insert(authorInserts);

        if (authorsInsertError) throw authorsInsertError;
      }

      // Update Artists
      await supabase.from("trArtist").delete().eq("id_komik", comicId);

      if (selectedArtists.length > 0) {
        const artistInserts = selectedArtists.map((artistId) => ({
          id_komik: comicId,
          id_artist: artistId,
        }));

        const { error: artistsInsertError } = await supabase
          .from("trArtist")
          .insert(artistInserts);

        if (artistsInsertError) throw artistsInsertError;
      }

      // Update Genres
      await supabase.from("trGenre").delete().eq("id_komik", comicId);

      if (selectedGenres.length > 0) {
        const genreInserts = selectedGenres.map((genreId) => ({
          id_komik: comicId,
          id_genre: genreId,
        }));

        const { error: genresInsertError } = await supabase
          .from("trGenre")
          .insert(genreInserts);

        if (genresInsertError) throw genresInsertError;
      }

      // Update Formats
      await supabase.from("trFormat").delete().eq("id_komik", comicId);

      if (selectedFormats.length > 0) {
        const formatInserts = selectedFormats.map((formatId) => ({
          id_komik: comicId,
          id_format: formatId,
        }));

        const { error: formatsInsertError } = await supabase
          .from("trFormat")
          .insert(formatInserts);

        if (formatsInsertError) throw formatsInsertError;
      }

      alert("Metadata updated successfully!");
    } catch (error) {
      console.error("Error saving metadata:", error);
      alert("Failed to save metadata. Please try again.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleAddNewAuthor = async () => {
    if (!newAuthorName.trim()) return;

    try {
      const { data, error } = await supabase
        .from("mAuthor")
        .insert({ name: newAuthorName.trim() })
        .select()
        .single();

      if (error) throw error;

      setAuthors([...authors, data]);
      setSelectedAuthors([...selectedAuthors, data.id]);
      setNewAuthorName("");
    } catch (error) {
      console.error("Error adding new author:", error);
      alert("Failed to add new author. Please try again.");
    }
  };

  const handleAddNewArtist = async () => {
    if (!newArtistName.trim()) return;

    try {
      const { data, error } = await supabase
        .from("mArtist")
        .insert({ name: newArtistName.trim() })
        .select()
        .single();

      if (error) throw error;

      setArtists([...artists, data]);
      setSelectedArtists([...selectedArtists, data.id]);
      setNewArtistName("");
    } catch (error) {
      console.error("Error adding new artist:", error);
      alert("Failed to add new artist. Please try again.");
    }
  };

  const handleAddNewGenre = async () => {
    if (!newGenreName.trim()) return;

    try {
      const { data, error } = await supabase
        .from("mGenre")
        .insert({ name: newGenreName.trim() })
        .select()
        .single();

      if (error) throw error;

      setGenres([...genres, data]);
      setSelectedGenres([...selectedGenres, data.id]);
      setNewGenreName("");
    } catch (error) {
      console.error("Error adding new genre:", error);
      alert("Failed to add new genre. Please try again.");
    }
  };

  const handleAddNewFormat = async () => {
    if (!newFormatName.trim()) return;

    try {
      const { data, error } = await supabase
        .from("mFormat")
        .insert({ name: newFormatName.trim() })
        .select()
        .single();

      if (error) throw error;

      setFormats([...formats, data]);
      setSelectedFormats([...selectedFormats, data.id]);
      setNewFormatName("");
    } catch (error) {
      console.error("Error adding new format:", error);
      alert("Failed to add new format. Please try again.");
    }
  };

  const navigateBack = () => {
    router.push(`/admin?view=comics-list`);
  };

  const handleAuthorCheckChange = (authorId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedAuthors([...selectedAuthors, authorId]);
    } else {
      setSelectedAuthors(selectedAuthors.filter((id) => id !== authorId));
    }
  };

  const handleArtistCheckChange = (artistId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedArtists([...selectedArtists, artistId]);
    } else {
      setSelectedArtists(selectedArtists.filter((id) => id !== artistId));
    }
  };

  const handleGenreCheckChange = (genreId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedGenres([...selectedGenres, genreId]);
    } else {
      setSelectedGenres(selectedGenres.filter((id) => id !== genreId));
    }
  };

  const handleFormatCheckChange = (formatId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedFormats([...selectedFormats, formatId]);
    } else {
      setSelectedFormats(selectedFormats.filter((id) => id !== formatId));
    }
  };

  // Tambahkan filtered items berdasarkan query pencarian
  const filteredAuthors = useMemo(() => {
    return authors.filter(
      (author) =>
        !authorSearchQuery ||
        author.name.toLowerCase().includes(authorSearchQuery.toLowerCase())
    );
  }, [authors, authorSearchQuery]);

  const filteredArtists = useMemo(() => {
    return artists.filter(
      (artist) =>
        !artistSearchQuery ||
        artist.name.toLowerCase().includes(artistSearchQuery.toLowerCase())
    );
  }, [artists, artistSearchQuery]);

  const filteredGenres = useMemo(() => {
    return genres.filter(
      (genre) =>
        !genreSearchQuery ||
        genre.name.toLowerCase().includes(genreSearchQuery.toLowerCase())
    );
  }, [genres, genreSearchQuery]);

  const filteredFormats = useMemo(() => {
    return formats.filter(
      (format) =>
        !formatSearchQuery ||
        format.name.toLowerCase().includes(formatSearchQuery.toLowerCase())
    );
  }, [formats, formatSearchQuery]);

  // Tambahkan fungsi reset search saat pindah tab
  const resetSearchQueries = () => {
    setAuthorSearchQuery("");
    setArtistSearchQuery("");
    setGenreSearchQuery("");
    setFormatSearchQuery("");
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span className="ml-2">Loading metadata...</span>
      </div>
    );
  }

  return (
    <>
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Comic Metadata</h1>
          <p className="text-muted-foreground">
            {comicTitle || "Unknown Comic"}
          </p>
        </div>
        <Button variant="outline" onClick={navigateBack}>
          <ChevronLeft className="h-4 w-4 mr-2" />
          Back to Comics
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Manage Metadata</CardTitle>
          <CardDescription>
            Add or remove authors, artists, genres, and formats for this comic.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs
            defaultValue="authors"
            className="w-full"
            onValueChange={resetSearchQueries}
          >
            <TabsList className="grid grid-cols-4 mb-4">
              <TabsTrigger value="authors" className="flex items-center">
                <Users className="h-4 w-4 mr-2" />
                Authors
              </TabsTrigger>
              <TabsTrigger value="artists" className="flex items-center">
                <Brush className="h-4 w-4 mr-2" />
                Artists
              </TabsTrigger>
              <TabsTrigger value="genres" className="flex items-center">
                <Tag className="h-4 w-4 mr-2" />
                Genres
              </TabsTrigger>
              <TabsTrigger value="formats" className="flex items-center">
                <FileText className="h-4 w-4 mr-2" />
                Formats
              </TabsTrigger>
            </TabsList>

            {/* Authors Tab */}
            <TabsContent value="authors" className="space-y-4">
              <div className="flex items-end gap-2">
                <div className="flex-grow">
                  <Label htmlFor="new-author">Add New Author</Label>
                  <Input
                    id="new-author"
                    placeholder="Enter author name"
                    value={newAuthorName}
                    onChange={(e) => setNewAuthorName(e.target.value)}
                  />
                </div>
                <Button onClick={handleAddNewAuthor} type="button">
                  <PlusCircle className="h-4 w-4 mr-2" />
                  Add
                </Button>
              </div>

              <div className="border rounded-md p-4 max-h-[400px] overflow-y-auto">
                <div className="mb-2 font-medium">Selected Authors</div>
                <div className="flex flex-wrap gap-1 mb-4">
                  {selectedAuthors.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No authors selected
                    </p>
                  ) : (
                    selectedAuthors.map((authorId) => {
                      const author = authors.find((a) => a.id === authorId);
                      return author ? (
                        <Badge
                          key={author.id}
                          variant="secondary"
                          className="flex items-center gap-1"
                        >
                          {author.name}
                          <button
                            onClick={() =>
                              setSelectedAuthors(
                                selectedAuthors.filter((id) => id !== author.id)
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ) : null;
                    })
                  )}
                </div>

                <div className="space-y-2">
                  <div className="font-medium mb-2">Available Authors</div>
                  <div className="mb-2">
                    <Input
                      placeholder="Search authors..."
                      value={authorSearchQuery}
                      onChange={(e) => setAuthorSearchQuery(e.target.value)}
                      className="max-w-sm"
                    />
                  </div>
                  <div className="flex flex-wrap gap-1">
                    {filteredAuthors
                      .filter((author) => !selectedAuthors.includes(author.id))
                      .map((author) => (
                        <div
                          key={author.id}
                          className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                        >
                          <Checkbox
                            id={`author-${author.id}`}
                            checked={selectedAuthors.includes(author.id)}
                            onCheckedChange={(checked: CheckedState) =>
                              handleAuthorCheckChange(author.id, checked)
                            }
                          />
                          <Label
                            htmlFor={`author-${author.id}`}
                            className="text-sm cursor-pointer"
                          >
                            {author.name}
                          </Label>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            {/* Artists Tab */}
            <TabsContent value="artists" className="space-y-4">
              <div className="flex items-end gap-2">
                <div className="flex-grow">
                  <Label htmlFor="new-artist">Add New Artist</Label>
                  <Input
                    id="new-artist"
                    placeholder="Enter artist name"
                    value={newArtistName}
                    onChange={(e) => setNewArtistName(e.target.value)}
                  />
                </div>
                <Button onClick={handleAddNewArtist} type="button">
                  <PlusCircle className="h-4 w-4 mr-2" />
                  Add
                </Button>
              </div>

              <div className="border rounded-md p-4 max-h-[400px] overflow-y-auto">
                <div className="mb-2 font-medium">Selected Artists</div>
                <div className="flex flex-wrap gap-1 mb-4">
                  {selectedArtists.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No artists selected
                    </p>
                  ) : (
                    selectedArtists.map((artistId) => {
                      const artist = artists.find((a) => a.id === artistId);
                      return artist ? (
                        <Badge
                          key={artist.id}
                          variant="secondary"
                          className="flex items-center gap-1"
                        >
                          {artist.name}
                          <button
                            onClick={() =>
                              setSelectedArtists(
                                selectedArtists.filter((id) => id !== artist.id)
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ) : null;
                    })
                  )}
                </div>

                <div className="space-y-2">
                  <div className="font-medium mb-2">Available Artists</div>
                  <div className="mb-2">
                    <Input
                      placeholder="Search artists..."
                      value={artistSearchQuery}
                      onChange={(e) => setArtistSearchQuery(e.target.value)}
                      className="max-w-sm"
                    />
                  </div>
                  <div className="flex flex-wrap gap-1">
                    {filteredArtists
                      .filter((artist) => !selectedArtists.includes(artist.id))
                      .map((artist) => (
                        <div
                          key={artist.id}
                          className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                        >
                          <Checkbox
                            id={`artist-${artist.id}`}
                            checked={selectedArtists.includes(artist.id)}
                            onCheckedChange={(checked: CheckedState) =>
                              handleArtistCheckChange(artist.id, checked)
                            }
                          />
                          <Label
                            htmlFor={`artist-${artist.id}`}
                            className="text-sm cursor-pointer"
                          >
                            {artist.name}
                          </Label>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            {/* Genres Tab */}
            <TabsContent value="genres" className="space-y-4">
              <div className="flex items-end gap-2">
                <div className="flex-grow">
                  <Label htmlFor="new-genre">Add New Genre</Label>
                  <Input
                    id="new-genre"
                    placeholder="Enter genre name"
                    value={newGenreName}
                    onChange={(e) => setNewGenreName(e.target.value)}
                  />
                </div>
                <Button onClick={handleAddNewGenre} type="button">
                  <PlusCircle className="h-4 w-4 mr-2" />
                  Add
                </Button>
              </div>

              <div className="border rounded-md p-4 max-h-[400px] overflow-y-auto">
                <div className="mb-2 font-medium">Selected Genres</div>
                <div className="flex flex-wrap gap-1 mb-4">
                  {selectedGenres.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No genres selected
                    </p>
                  ) : (
                    selectedGenres.map((genreId) => {
                      const genre = genres.find((g) => g.id === genreId);
                      return genre ? (
                        <Badge
                          key={genre.id}
                          variant="secondary"
                          className="flex items-center gap-1"
                        >
                          {genre.name}
                          <button
                            onClick={() =>
                              setSelectedGenres(
                                selectedGenres.filter((id) => id !== genre.id)
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ) : null;
                    })
                  )}
                </div>

                <div className="space-y-2">
                  <div className="font-medium mb-2">Available Genres</div>
                  <div className="mb-2">
                    <Input
                      placeholder="Search genres..."
                      value={genreSearchQuery}
                      onChange={(e) => setGenreSearchQuery(e.target.value)}
                      className="max-w-sm"
                    />
                  </div>
                  <div className="flex flex-wrap gap-1">
                    {filteredGenres
                      .filter((genre) => !selectedGenres.includes(genre.id))
                      .map((genre) => (
                        <div
                          key={genre.id}
                          className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                        >
                          <Checkbox
                            id={`genre-${genre.id}`}
                            checked={selectedGenres.includes(genre.id)}
                            onCheckedChange={(checked: CheckedState) =>
                              handleGenreCheckChange(genre.id, checked)
                            }
                          />
                          <Label
                            htmlFor={`genre-${genre.id}`}
                            className="text-sm cursor-pointer"
                          >
                            {genre.name}
                          </Label>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            </TabsContent>

            {/* Formats Tab */}
            <TabsContent value="formats" className="space-y-4">
              <div className="flex items-end gap-2">
                <div className="flex-grow">
                  <Label htmlFor="new-format">Add New Format</Label>
                  <Input
                    id="new-format"
                    placeholder="Enter format name"
                    value={newFormatName}
                    onChange={(e) => setNewFormatName(e.target.value)}
                  />
                </div>
                <Button onClick={handleAddNewFormat} type="button">
                  <PlusCircle className="h-4 w-4 mr-2" />
                  Add
                </Button>
              </div>

              <div className="border rounded-md p-4 max-h-[400px] overflow-y-auto">
                <div className="mb-2 font-medium">Selected Formats</div>
                <div className="flex flex-wrap gap-1 mb-4">
                  {selectedFormats.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No formats selected
                    </p>
                  ) : (
                    selectedFormats.map((formatId) => {
                      const format = formats.find((f) => f.id === formatId);
                      return format ? (
                        <Badge
                          key={format.id}
                          variant="secondary"
                          className="flex items-center gap-1"
                        >
                          {format.name}
                          <button
                            onClick={() =>
                              setSelectedFormats(
                                selectedFormats.filter((id) => id !== format.id)
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ) : null;
                    })
                  )}
                </div>

                <div className="space-y-2">
                  <div className="font-medium mb-2">Available Formats</div>
                  <div className="mb-2">
                    <Input
                      placeholder="Search formats..."
                      value={formatSearchQuery}
                      onChange={(e) => setFormatSearchQuery(e.target.value)}
                      className="max-w-sm"
                    />
                  </div>
                  <div className="flex flex-wrap gap-1">
                    {filteredFormats
                      .filter(
                        (format: Format) => !selectedFormats.includes(format.id)
                      )
                      .map((format: Format) => (
                        <div
                          key={format.id}
                          className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                        >
                          <Checkbox
                            id={`format-${format.id}`}
                            checked={selectedFormats.includes(format.id)}
                            onCheckedChange={(checked: CheckedState) =>
                              handleFormatCheckChange(format.id, checked)
                            }
                          />
                          <Label
                            htmlFor={`format-${format.id}`}
                            className="text-sm cursor-pointer"
                          >
                            {format.name}
                          </Label>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
        <CardFooter className="flex justify-end space-x-2">
          <Button variant="outline" onClick={navigateBack}>
            Cancel
          </Button>
          <Button onClick={handleSaveMetadata} disabled={submitting}>
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Saving...
              </>
            ) : (
              "Save Metadata"
            )}
          </Button>
        </CardFooter>
      </Card>
    </>
  );
}
