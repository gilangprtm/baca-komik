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

  // Modifikasi state loading menjadi per-jenis metadata
  const [isLoadingAuthors, setIsLoadingAuthors] = useState(false);
  const [isLoadingArtists, setIsLoadingArtists] = useState(false);
  const [isLoadingGenres, setIsLoadingGenres] = useState(false);
  const [isLoadingFormats, setIsLoadingFormats] = useState(false);
  const [isLoadingSelected, setIsLoadingSelected] = useState(true);

  // Tambahkan state untuk tracking tab mana yang sudah dimuat
  const [loadedTabs, setLoadedTabs] = useState<Record<string, boolean>>({
    authors: false,
    artists: false,
    genres: false,
    formats: false,
  });

  // Modifikasi state untuk hanya menyimpan IDs yang dipilih, bukan item lengkap
  const [selectedAuthorIds, setSelectedAuthorIds] = useState<string[]>([]);
  const [selectedArtistIds, setSelectedArtistIds] = useState<string[]>([]);
  const [selectedGenreIds, setSelectedGenreIds] = useState<string[]>([]);
  const [selectedFormatIds, setSelectedFormatIds] = useState<string[]>([]);

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

    // Modifikasi useEffect untuk hanya memuat IDs yang dipilih
    async function fetchSelectedData() {
      setIsLoadingSelected(true);
      try {
        // Fetch comic's selected authors
        const { data: comicAuthors, error: comicAuthorsError } = await supabase
          .from("trAuthor")
          .select("id_author")
          .eq("id_komik", comicId as string);

        if (comicAuthorsError) throw comicAuthorsError;
        setSelectedAuthorIds(comicAuthors.map((item) => item.id_author) || []);

        // Fetch comic's selected artists
        const { data: comicArtists, error: comicArtistsError } = await supabase
          .from("trArtist")
          .select("id_artist")
          .eq("id_komik", comicId as string);

        if (comicArtistsError) throw comicArtistsError;
        setSelectedArtistIds(comicArtists.map((item) => item.id_artist) || []);

        // Fetch comic's selected genres
        const { data: comicGenres, error: comicGenresError } = await supabase
          .from("trGenre")
          .select("id_genre")
          .eq("id_komik", comicId as string);

        if (comicGenresError) throw comicGenresError;
        setSelectedGenreIds(comicGenres.map((item) => item.id_genre) || []);

        // Fetch comic's selected formats
        const { data: comicFormats, error: comicFormatsError } = await supabase
          .from("trFormat")
          .select("id_format")
          .eq("id_komik", comicId as string);

        if (comicFormatsError) throw comicFormatsError;
        setSelectedFormatIds(comicFormats.map((item) => item.id_format) || []);

        // Kemudian load authors secara default
        await fetchAuthors();
      } catch (error) {
        console.error("Error fetching selected metadata:", error);
        alert("Failed to load metadata. Please try again.");
      } finally {
        setIsLoadingSelected(false);
      }
    }

    fetchSelectedData();
  }, [comicId, router, supabase]);

  // Modifikasi fungsi fetchAuthors untuk juga memuat author yang dipilih jika belum ada di data
  const fetchAuthors = async () => {
    if (loadedTabs.authors) return; // Skip jika sudah dimuat

    setIsLoadingAuthors(true);
    try {
      // Fetch semua author available
      const { data, error } = await supabase
        .from("mAuthor")
        .select("*")
        .order("name");

      if (error) throw error;
      setAuthors(data || []);

      // Periksa jika ada author yang dipilih tapi belum ada di daftar author
      const missingAuthorIds = selectedAuthorIds.filter(
        (id) => !data?.some((author) => author.id === id)
      );

      // Jika ada yang hilang, fetch secara terpisah
      if (missingAuthorIds.length > 0) {
        const { data: missingAuthors, error: missingError } = await supabase
          .from("mAuthor")
          .select("*")
          .in("id", missingAuthorIds);

        if (missingError) throw missingError;

        // Gabungkan dengan data yang sudah ada
        if (missingAuthors && missingAuthors.length > 0) {
          setAuthors([...data, ...missingAuthors]);
        }
      }

      setLoadedTabs((prev) => ({ ...prev, authors: true }));
    } catch (error) {
      console.error("Error fetching authors:", error);
    } finally {
      setIsLoadingAuthors(false);
    }
  };

  const fetchArtists = async () => {
    if (loadedTabs.artists) return;

    setIsLoadingArtists(true);
    try {
      const { data, error } = await supabase
        .from("mArtist")
        .select("*")
        .order("name");

      if (error) throw error;
      setArtists(data || []);

      // Periksa jika ada artist yang dipilih tapi belum ada di daftar
      const missingArtistIds = selectedArtistIds.filter(
        (id) => !data?.some((artist) => artist.id === id)
      );

      if (missingArtistIds.length > 0) {
        const { data: missingArtists, error: missingError } = await supabase
          .from("mArtist")
          .select("*")
          .in("id", missingArtistIds);

        if (missingError) throw missingError;

        if (missingArtists && missingArtists.length > 0) {
          setArtists([...data, ...missingArtists]);
        }
      }

      setLoadedTabs((prev) => ({ ...prev, artists: true }));
    } catch (error) {
      console.error("Error fetching artists:", error);
    } finally {
      setIsLoadingArtists(false);
    }
  };

  const fetchGenres = async () => {
    if (loadedTabs.genres) return; // Skip jika sudah dimuat

    setIsLoadingGenres(true);
    try {
      const { data, error } = await supabase
        .from("mGenre")
        .select("*")
        .order("name");

      if (error) throw error;
      setGenres(data || []);
      setLoadedTabs((prev) => ({ ...prev, genres: true }));
    } catch (error) {
      console.error("Error fetching genres:", error);
    } finally {
      setIsLoadingGenres(false);
    }
  };

  const fetchFormats = async () => {
    if (loadedTabs.formats) return; // Skip jika sudah dimuat

    setIsLoadingFormats(true);
    try {
      const { data, error } = await supabase
        .from("mFormat")
        .select("*")
        .order("name");

      if (error) throw error;
      setFormats(data || []);
      setLoadedTabs((prev) => ({ ...prev, formats: true }));
    } catch (error) {
      console.error("Error fetching formats:", error);
    } finally {
      setIsLoadingFormats(false);
    }
  };

  // Modifikasi handler untuk tab changes - load data jika belum diload
  const handleTabChange = (tab: string) => {
    resetSearchQueries();

    switch (tab) {
      case "authors":
        fetchAuthors();
        break;
      case "artists":
        fetchArtists();
        break;
      case "genres":
        fetchGenres();
        break;
      case "formats":
        fetchFormats();
        break;
    }
  };

  // Update handler checkbox untuk menggunakan IDs baru
  const handleAuthorCheckChange = (authorId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedAuthorIds([...selectedAuthorIds, authorId]);
    } else {
      setSelectedAuthorIds(selectedAuthorIds.filter((id) => id !== authorId));
    }
  };

  const handleArtistCheckChange = (artistId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedArtistIds([...selectedArtistIds, artistId]);
    } else {
      setSelectedArtistIds(selectedArtistIds.filter((id) => id !== artistId));
    }
  };

  const handleGenreCheckChange = (genreId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedGenreIds([...selectedGenreIds, genreId]);
    } else {
      setSelectedGenreIds(selectedGenreIds.filter((id) => id !== genreId));
    }
  };

  const handleFormatCheckChange = (formatId: string, checked: CheckedState) => {
    if (checked === true) {
      setSelectedFormatIds([...selectedFormatIds, formatId]);
    } else {
      setSelectedFormatIds(selectedFormatIds.filter((id) => id !== formatId));
    }
  };

  // Update fungsi save metadata untuk menggunakan state IDs baru
  const handleSaveMetadata = async () => {
    if (!comicId) return;

    setIsLoadingSelected(true);

    try {
      // Update Authors
      await supabase.from("trAuthor").delete().eq("id_komik", comicId);

      if (selectedAuthorIds.length > 0) {
        const authorInserts = selectedAuthorIds.map((authorId) => ({
          id_komik: comicId,
          id_author: authorId,
        }));

        const { error: authorsInsertError } = await supabase
          .from("trAuthor")
          .insert(authorInserts);

        if (authorsInsertError) throw authorsInsertError;
      }

      // Update Artists dengan cara yang sama
      await supabase.from("trArtist").delete().eq("id_komik", comicId);

      if (selectedArtistIds.length > 0) {
        const artistInserts = selectedArtistIds.map((artistId) => ({
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

      if (selectedGenreIds.length > 0) {
        const genreInserts = selectedGenreIds.map((genreId) => ({
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

      if (selectedFormatIds.length > 0) {
        const formatInserts = selectedFormatIds.map((formatId) => ({
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
      setIsLoadingSelected(false);
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
      setSelectedAuthorIds([...selectedAuthorIds, data.id]);
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
      setSelectedArtistIds([...selectedArtistIds, data.id]);
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
      setSelectedGenreIds([...selectedGenreIds, data.id]);
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
      setSelectedFormatIds([...selectedFormatIds, data.id]);
      setNewFormatName("");
    } catch (error) {
      console.error("Error adding new format:", error);
      alert("Failed to add new format. Please try again.");
    }
  };

  const navigateBack = () => {
    router.push(`/admin?view=comics-list`);
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

  // Hapus isLoading umum dan gunakan loading state per-tab
  if (isLoadingSelected) {
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
            onValueChange={handleTabChange}
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
                  {selectedAuthorIds.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No authors selected
                    </p>
                  ) : (
                    selectedAuthorIds.map((authorId) => {
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
                              setSelectedAuthorIds(
                                selectedAuthorIds.filter(
                                  (id) => id !== author.id
                                )
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      ) : (
                        <Badge
                          key={authorId}
                          variant="secondary"
                          className="flex items-center gap-1"
                        >
                          ID: {authorId.substring(0, 8)}...
                          <button
                            onClick={() =>
                              setSelectedAuthorIds(
                                selectedAuthorIds.filter(
                                  (id) => id !== authorId
                                )
                              )
                            }
                            className="ml-1 hover:text-destructive"
                          >
                            <X className="h-3 w-3" />
                          </button>
                        </Badge>
                      );
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

                  {isLoadingAuthors ? (
                    <div className="flex justify-center py-4">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    </div>
                  ) : (
                    <div className="flex flex-wrap gap-1">
                      {filteredAuthors
                        .filter(
                          (author) => !selectedAuthorIds.includes(author.id)
                        )
                        .map((author) => (
                          <div
                            key={author.id}
                            className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                          >
                            <Checkbox
                              id={`author-${author.id}`}
                              checked={selectedAuthorIds.includes(author.id)}
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
                  )}
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
                  {selectedArtistIds.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No artists selected
                    </p>
                  ) : (
                    selectedArtistIds.map((artistId) => {
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
                              setSelectedArtistIds(
                                selectedArtistIds.filter(
                                  (id) => id !== artist.id
                                )
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

                  {isLoadingArtists ? (
                    <div className="flex justify-center py-4">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    </div>
                  ) : (
                    <div className="flex flex-wrap gap-1">
                      {filteredArtists
                        .filter(
                          (artist) => !selectedArtistIds.includes(artist.id)
                        )
                        .map((artist) => (
                          <div
                            key={artist.id}
                            className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                          >
                            <Checkbox
                              id={`artist-${artist.id}`}
                              checked={selectedArtistIds.includes(artist.id)}
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
                  )}
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
                  {selectedGenreIds.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No genres selected
                    </p>
                  ) : (
                    selectedGenreIds.map((genreId) => {
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
                              setSelectedGenreIds(
                                selectedGenreIds.filter((id) => id !== genre.id)
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

                  {isLoadingGenres ? (
                    <div className="flex justify-center py-4">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    </div>
                  ) : (
                    <div className="flex flex-wrap gap-1">
                      {filteredGenres
                        .filter((genre) => !selectedGenreIds.includes(genre.id))
                        .map((genre) => (
                          <div
                            key={genre.id}
                            className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                          >
                            <Checkbox
                              id={`genre-${genre.id}`}
                              checked={selectedGenreIds.includes(genre.id)}
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
                  )}
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
                  {selectedFormatIds.length === 0 ? (
                    <p className="text-sm text-muted-foreground">
                      No formats selected
                    </p>
                  ) : (
                    selectedFormatIds.map((formatId) => {
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
                              setSelectedFormatIds(
                                selectedFormatIds.filter(
                                  (id) => id !== format.id
                                )
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

                  {isLoadingFormats ? (
                    <div className="flex justify-center py-4">
                      <Loader2 className="h-6 w-6 animate-spin text-primary" />
                    </div>
                  ) : (
                    <div className="flex flex-wrap gap-1">
                      {filteredFormats
                        .filter(
                          (format: Format) =>
                            !selectedFormatIds.includes(format.id)
                        )
                        .map((format: Format) => (
                          <div
                            key={format.id}
                            className="flex items-center space-x-1 bg-muted/30 px-2 py-0.5 rounded-sm"
                          >
                            <Checkbox
                              id={`format-${format.id}`}
                              checked={selectedFormatIds.includes(format.id)}
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
                  )}
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
        <CardFooter className="flex justify-end space-x-2">
          <Button variant="outline" onClick={navigateBack}>
            Cancel
          </Button>
          <Button onClick={handleSaveMetadata} disabled={isLoadingSelected}>
            {isLoadingSelected ? (
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
