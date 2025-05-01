"use client";

import { useState, useEffect } from "react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";
import { useRouter } from "next/navigation";
import { Database } from "@/lib/supabase/database.types";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
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
import { FormEvent } from "react";

interface Genre {
  id: string;
  name: string;
}

interface Author {
  id: string;
  name: string;
}

interface Artist {
  id: string;
  name: string;
}

interface Format {
  id: string;
  name: string;
}

export default function AddComic() {
  const router = useRouter();
  const supabase = createClientComponentClient<Database>();

  // Form state
  const [title, setTitle] = useState("");
  const [alternativeTitle, setAlternativeTitle] = useState("");
  const [description, setDescription] = useState("");
  const [coverImageUrl, setCoverImageUrl] = useState("");
  const [releaseYear, setReleaseYear] = useState<number | "">("");
  const [country, setCountry] = useState<"KR" | "JPN" | "CN">("JPN");

  // Related data
  const [genres, setGenres] = useState<Genre[]>([]);
  const [selectedGenres, setSelectedGenres] = useState<string[]>([]);

  const [authors, setAuthors] = useState<Author[]>([]);
  const [selectedAuthors, setSelectedAuthors] = useState<string[]>([]);

  const [artists, setArtists] = useState<Artist[]>([]);
  const [selectedArtists, setSelectedArtists] = useState<string[]>([]);

  const [formats, setFormats] = useState<Format[]>([]);
  const [selectedFormats, setSelectedFormats] = useState<string[]>([]);

  // Loading and error states
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Verify authentication
    async function checkAuth() {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session) {
        router.push("/auth/login");
        return false;
      }
      return true;
    }

    // Load required data for form
    async function loadFormData() {
      const isAuthenticated = await checkAuth();
      if (!isAuthenticated) return;

      // Fetch genres
      const { data: genreData } = await supabase
        .from("mGenre")
        .select("*")
        .order("name");
      if (genreData) setGenres(genreData as Genre[]);

      // Fetch authors
      const { data: authorData } = await supabase
        .from("mAuthor")
        .select("*")
        .order("name");
      if (authorData) setAuthors(authorData as Author[]);

      // Fetch artists
      const { data: artistData } = await supabase
        .from("mArtist")
        .select("*")
        .order("name");
      if (artistData) setArtists(artistData as Artist[]);

      // Fetch formats
      const { data: formatData } = await supabase
        .from("mFormat")
        .select("*")
        .order("name");
      if (formatData) setFormats(formatData as Format[]);
    }

    loadFormData();
  }, [router, supabase]);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      // Validasi data
      if (!title) {
        setError("Judul komik wajib diisi");
        return;
      }

      // Insert komik baru
      const { data: comicData, error: comicError } = await supabase
        .from("mKomik")
        .insert({
          title,
          alternative_title: alternativeTitle || null,
          description: description || null,
          cover_image_url: coverImageUrl || null,
          release_year: releaseYear || null,
          country_id: country,
        })
        .select()
        .single();

      if (comicError) {
        throw comicError;
      }

      const comicId = comicData.id;

      // Insert genres
      if (selectedGenres.length > 0) {
        const genreRelations = selectedGenres.map((genreId) => ({
          id_komik: comicId,
          id_genre: genreId,
        }));

        const { error: genreError } = await supabase
          .from("trGenre")
          .insert(genreRelations);

        if (genreError) {
          throw genreError;
        }
      }

      // Insert authors
      if (selectedAuthors.length > 0) {
        const authorRelations = selectedAuthors.map((authorId) => ({
          id_komik: comicId,
          id_author: authorId,
        }));

        const { error: authorError } = await supabase
          .from("trAuthor")
          .insert(authorRelations);

        if (authorError) {
          throw authorError;
        }
      }

      // Insert artists
      if (selectedArtists.length > 0) {
        const artistRelations = selectedArtists.map((artistId) => ({
          id_komik: comicId,
          id_artist: artistId,
        }));

        const { error: artistError } = await supabase
          .from("trArtist")
          .insert(artistRelations);

        if (artistError) {
          throw artistError;
        }
      }

      // Insert formats
      if (selectedFormats.length > 0) {
        const formatRelations = selectedFormats.map((formatId) => ({
          id_komik: comicId,
          id_format: formatId,
        }));

        const { error: formatError } = await supabase
          .from("trFormat")
          .insert(formatRelations);

        if (formatError) {
          throw formatError;
        }
      }

      // Redirect ke halaman daftar komik
      router.push("/admin/comics");
    } catch (error: any) {
      console.error("Error adding comic:", error);
      setError(error.message || "Terjadi kesalahan saat menambahkan komik");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-4 md:p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Tambah Komik Baru</h1>
          <p className="text-sm text-muted-foreground">
            Tambahkan komik baru ke database
          </p>
        </div>
        <Button onClick={() => router.push("/admin/comics")}>Kembali</Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Form Komik</CardTitle>
        </CardHeader>
        <CardContent>
          {error && (
            <div className="bg-destructive/15 text-destructive rounded p-3 mb-4 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div>
                  <Label htmlFor="title">Judul Komik *</Label>
                  <Input
                    id="title"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    required
                  />
                </div>

                <div>
                  <Label htmlFor="alternativeTitle">Judul Alternatif</Label>
                  <Input
                    id="alternativeTitle"
                    value={alternativeTitle}
                    onChange={(e) => setAlternativeTitle(e.target.value)}
                  />
                </div>

                <div>
                  <Label htmlFor="country">Negara Asal *</Label>
                  <Select
                    value={country}
                    onValueChange={(value) =>
                      setCountry(value as "KR" | "JPN" | "CN")
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Pilih negara" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="JPN">Jepang (JPN)</SelectItem>
                      <SelectItem value="KR">Korea (KR)</SelectItem>
                      <SelectItem value="CN">China (CN)</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label htmlFor="releaseYear">Tahun Rilis</Label>
                  <Input
                    id="releaseYear"
                    type="number"
                    value={releaseYear.toString()}
                    onChange={(e) => {
                      const value = e.target.value;
                      setReleaseYear(value === "" ? "" : parseInt(value));
                    }}
                  />
                </div>

                <div>
                  <Label htmlFor="coverImageUrl">URL Cover Image</Label>
                  <Input
                    id="coverImageUrl"
                    type="url"
                    value={coverImageUrl}
                    onChange={(e) => setCoverImageUrl(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <Label htmlFor="description">Deskripsi</Label>
                  <Textarea
                    id="description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    rows={5}
                  />
                </div>

                <div>
                  <Label>Genre</Label>
                  <div className="border rounded-md p-3 h-24 overflow-y-auto space-y-2">
                    {genres.map((genre) => (
                      <div key={genre.id} className="flex items-center">
                        <input
                          type="checkbox"
                          id={`genre-${genre.id}`}
                          checked={selectedGenres.includes(genre.id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setSelectedGenres([...selectedGenres, genre.id]);
                            } else {
                              setSelectedGenres(
                                selectedGenres.filter((id) => id !== genre.id)
                              );
                            }
                          }}
                          className="mr-2"
                        />
                        <label
                          htmlFor={`genre-${genre.id}`}
                          className="text-sm"
                        >
                          {genre.name}
                        </label>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Penulis</Label>
                    <div className="border rounded-md p-3 h-24 overflow-y-auto space-y-2">
                      {authors.map((author) => (
                        <div key={author.id} className="flex items-center">
                          <input
                            type="checkbox"
                            id={`author-${author.id}`}
                            checked={selectedAuthors.includes(author.id)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setSelectedAuthors([
                                  ...selectedAuthors,
                                  author.id,
                                ]);
                              } else {
                                setSelectedAuthors(
                                  selectedAuthors.filter(
                                    (id) => id !== author.id
                                  )
                                );
                              }
                            }}
                            className="mr-2"
                          />
                          <label
                            htmlFor={`author-${author.id}`}
                            className="text-sm"
                          >
                            {author.name}
                          </label>
                        </div>
                      ))}
                    </div>
                  </div>

                  <div>
                    <Label>Artis</Label>
                    <div className="border rounded-md p-3 h-24 overflow-y-auto space-y-2">
                      {artists.map((artist) => (
                        <div key={artist.id} className="flex items-center">
                          <input
                            type="checkbox"
                            id={`artist-${artist.id}`}
                            checked={selectedArtists.includes(artist.id)}
                            onChange={(e) => {
                              if (e.target.checked) {
                                setSelectedArtists([
                                  ...selectedArtists,
                                  artist.id,
                                ]);
                              } else {
                                setSelectedArtists(
                                  selectedArtists.filter(
                                    (id) => id !== artist.id
                                  )
                                );
                              }
                            }}
                            className="mr-2"
                          />
                          <label
                            htmlFor={`artist-${artist.id}`}
                            className="text-sm"
                          >
                            {artist.name}
                          </label>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-2">
              <Button
                type="button"
                variant="outline"
                onClick={() => router.push("/admin/comics")}
              >
                Batal
              </Button>
              <Button type="submit" disabled={loading}>
                {loading ? "Menyimpan..." : "Simpan Komik"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
