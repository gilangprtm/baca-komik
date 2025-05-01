export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  public: {
    Tables: {
      mArtist: {
        Row: {
          id: string;
          name: string;
        };
        Insert: {
          id?: string;
          name: string;
        };
        Update: {
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      mAuthor: {
        Row: {
          id: string;
          name: string;
        };
        Insert: {
          id?: string;
          name: string;
        };
        Update: {
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      mChapter: {
        Row: {
          chapter_number: number;
          created_date: string | null;
          id: string;
          id_komik: string;
          rating: number | null;
          release_date: string | null;
          thumbnail_image_url: string | null;
          view_count: number | null;
          vote_count: number | null;
        };
        Insert: {
          chapter_number: number;
          created_date?: string | null;
          id?: string;
          id_komik: string;
          rating?: number | null;
          release_date?: string | null;
          thumbnail_image_url?: string | null;
          view_count?: number | null;
          vote_count?: number | null;
        };
        Update: {
          chapter_number?: number;
          created_date?: string | null;
          id?: string;
          id_komik?: string;
          rating?: number | null;
          release_date?: string | null;
          thumbnail_image_url?: string | null;
          view_count?: number | null;
          vote_count?: number | null;
        };
        Relationships: [
          {
            foreignKeyName: "mChapter_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      mFormat: {
        Row: {
          id: string;
          name: string;
        };
        Insert: {
          id?: string;
          name: string;
        };
        Update: {
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      mGenre: {
        Row: {
          id: string;
          name: string;
        };
        Insert: {
          id?: string;
          name: string;
        };
        Update: {
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      mKomik: {
        Row: {
          alternative_title: string | null;
          bookmark_count: number | null;
          country_id: Database["public"]["Enums"]["country"];
          cover_image_url: string | null;
          created_date: string | null;
          description: string | null;
          id: string;
          rank: number | null;
          release_year: number | null;
          title: string;
          view_count: number | null;
          vote_count: number | null;
        };
        Insert: {
          alternative_title?: string | null;
          bookmark_count?: number | null;
          country_id: Database["public"]["Enums"]["country"];
          cover_image_url?: string | null;
          created_date?: string | null;
          description?: string | null;
          id?: string;
          rank?: number | null;
          release_year?: number | null;
          title: string;
          view_count?: number | null;
          vote_count?: number | null;
        };
        Update: {
          alternative_title?: string | null;
          bookmark_count?: number | null;
          country_id?: Database["public"]["Enums"]["country"];
          cover_image_url?: string | null;
          created_date?: string | null;
          description?: string | null;
          id?: string;
          rank?: number | null;
          release_year?: number | null;
          title?: string;
          view_count?: number | null;
          vote_count?: number | null;
        };
        Relationships: [];
      };
      mKomikVote: {
        Row: {
          id_komik: string;
          id_user: string;
        };
        Insert: {
          id_komik: string;
          id_user: string;
        };
        Update: {
          id_komik?: string;
          id_user?: string;
        };
        Relationships: [
          {
            foreignKeyName: "mKomikVote_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "mKomikVote_id_user_fkey";
            columns: ["id_user"];
            isOneToOne: false;
            referencedRelation: "mUser";
            referencedColumns: ["id"];
          }
        ];
      };
      mPopular: {
        Row: {
          id_komik: string;
          type: Database["public"]["Enums"]["popular_period"];
        };
        Insert: {
          id_komik: string;
          type: Database["public"]["Enums"]["popular_period"];
        };
        Update: {
          id_komik?: string;
          type?: Database["public"]["Enums"]["popular_period"];
        };
        Relationships: [
          {
            foreignKeyName: "mPopular_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      mRecomed: {
        Row: {
          id_komik: string;
        };
        Insert: {
          id_komik: string;
        };
        Update: {
          id_komik?: string;
        };
        Relationships: [
          {
            foreignKeyName: "mRecomed_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: true;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      mUser: {
        Row: {
          avatar_url: string | null;
          created_date: string | null;
          id: string;
          name: string;
        };
        Insert: {
          avatar_url?: string | null;
          created_date?: string | null;
          id?: string;
          name: string;
        };
        Update: {
          avatar_url?: string | null;
          created_date?: string | null;
          id?: string;
          name?: string;
        };
        Relationships: [];
      };
      trArtist: {
        Row: {
          id_artist: string;
          id_komik: string;
        };
        Insert: {
          id_artist: string;
          id_komik: string;
        };
        Update: {
          id_artist?: string;
          id_komik?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trArtist_id_artist_fkey";
            columns: ["id_artist"];
            isOneToOne: false;
            referencedRelation: "mArtist";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trArtist_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      trAuthor: {
        Row: {
          id_author: string;
          id_komik: string;
        };
        Insert: {
          id_author: string;
          id_komik: string;
        };
        Update: {
          id_author?: string;
          id_komik?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trAuthor_id_author_fkey";
            columns: ["id_author"];
            isOneToOne: false;
            referencedRelation: "mAuthor";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trAuthor_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      trChapter: {
        Row: {
          id_chapter: string;
          page_number: number;
          page_url: string;
        };
        Insert: {
          id_chapter: string;
          page_number: number;
          page_url: string;
        };
        Update: {
          id_chapter?: string;
          page_number?: number;
          page_url?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trChapter_id_chapter_fkey";
            columns: ["id_chapter"];
            isOneToOne: false;
            referencedRelation: "mChapter";
            referencedColumns: ["id"];
          }
        ];
      };
      trChapterVote: {
        Row: {
          id_chapter: string;
          id_user: string;
        };
        Insert: {
          id_chapter: string;
          id_user: string;
        };
        Update: {
          id_chapter?: string;
          id_user?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trChapterVote_id_chapter_fkey";
            columns: ["id_chapter"];
            isOneToOne: false;
            referencedRelation: "mChapter";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trChapterVote_id_user_fkey";
            columns: ["id_user"];
            isOneToOne: false;
            referencedRelation: "mUser";
            referencedColumns: ["id"];
          }
        ];
      };
      trComments: {
        Row: {
          content: string;
          created_date: string | null;
          id: string;
          id_chapter: string | null;
          id_komik: string | null;
          id_user: string;
          parent_id: string | null;
        };
        Insert: {
          content: string;
          created_date?: string | null;
          id?: string;
          id_chapter?: string | null;
          id_komik?: string | null;
          id_user: string;
          parent_id?: string | null;
        };
        Update: {
          content?: string;
          created_date?: string | null;
          id?: string;
          id_chapter?: string | null;
          id_komik?: string | null;
          id_user?: string;
          parent_id?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: "trComments_id_chapter_fkey";
            columns: ["id_chapter"];
            isOneToOne: false;
            referencedRelation: "mChapter";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trComments_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trComments_id_user_fkey";
            columns: ["id_user"];
            isOneToOne: false;
            referencedRelation: "mUser";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trComments_parent_id_fkey";
            columns: ["parent_id"];
            isOneToOne: false;
            referencedRelation: "trComments";
            referencedColumns: ["id"];
          }
        ];
      };
      trFormat: {
        Row: {
          id_format: string;
          id_komik: string;
        };
        Insert: {
          id_format: string;
          id_komik: string;
        };
        Update: {
          id_format?: string;
          id_komik?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trFormat_id_format_fkey";
            columns: ["id_format"];
            isOneToOne: false;
            referencedRelation: "mFormat";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trFormat_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      trGenre: {
        Row: {
          id_genre: string;
          id_komik: string;
        };
        Insert: {
          id_genre: string;
          id_komik: string;
        };
        Update: {
          id_genre?: string;
          id_komik?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trGenre_id_genre_fkey";
            columns: ["id_genre"];
            isOneToOne: false;
            referencedRelation: "mGenre";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trGenre_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          }
        ];
      };
      trUserBookmark: {
        Row: {
          id_komik: string;
          id_user: string;
        };
        Insert: {
          id_komik: string;
          id_user: string;
        };
        Update: {
          id_komik?: string;
          id_user?: string;
        };
        Relationships: [
          {
            foreignKeyName: "trUserBookmark_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trUserBookmark_id_user_fkey";
            columns: ["id_user"];
            isOneToOne: false;
            referencedRelation: "mUser";
            referencedColumns: ["id"];
          }
        ];
      };
      trUserHistory: {
        Row: {
          id_chapter: string;
          id_komik: string | null;
          id_user: string;
          is_read: boolean | null;
          timestamp: string | null;
        };
        Insert: {
          id_chapter: string;
          id_komik?: string | null;
          id_user: string;
          is_read?: boolean | null;
          timestamp?: string | null;
        };
        Update: {
          id_chapter?: string;
          id_komik?: string | null;
          id_user?: string;
          is_read?: boolean | null;
          timestamp?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: "trUserHistory_id_chapter_fkey";
            columns: ["id_chapter"];
            isOneToOne: false;
            referencedRelation: "mChapter";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trUserHistory_id_komik_fkey";
            columns: ["id_komik"];
            isOneToOne: false;
            referencedRelation: "mKomik";
            referencedColumns: ["id"];
          },
          {
            foreignKeyName: "trUserHistory_id_user_fkey";
            columns: ["id_user"];
            isOneToOne: false;
            referencedRelation: "mUser";
            referencedColumns: ["id"];
          }
        ];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      increment_chapter_view_count: {
        Args: { chapter_id: string };
        Returns: undefined;
      };
      increment_comic_view_count: {
        Args: { comic_id: string };
        Returns: undefined;
      };
      update_chapter_vote_count: {
        Args: { chapter_id: string };
        Returns: undefined;
      };
      update_comic_bookmark_count: {
        Args: { comic_id: string };
        Returns: undefined;
      };
      update_comic_rank: {
        Args: { comic_id: string };
        Returns: undefined;
      };
      update_comic_vote_count: {
        Args: { comic_id: string };
        Returns: undefined;
      };
    };
    Enums: {
      country: "KR" | "JPN" | "CN";
      popular_period: "harian" | "mingguan" | "bulanan" | "all_time";
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DefaultSchema = Database[Extract<keyof Database, "public">];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? (Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      Database[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R;
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
      DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] &
      DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R;
    }
    ? R
    : never
  : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I;
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I;
    }
    ? I
    : never
  : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof Database },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U;
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U;
    }
    ? U
    : never
  : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof Database }
  ? Database[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database;
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never;

export const Constants = {
  public: {
    Enums: {
      country: ["KR", "JPN", "CN"],
      popular_period: ["harian", "mingguan", "bulanan", "all_time"],
    },
  },
} as const;
