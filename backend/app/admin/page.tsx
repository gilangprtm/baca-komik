"use client";

import { useSearchParams } from "next/navigation";
import { AdminLayout } from "@/components/admin-layout";
import dynamic from "next/dynamic";

// Dynamically load components
const DashboardContent = dynamic(() => import("@/components/admin/dashboard"), {
  ssr: false,
});
const ComicsContent = dynamic(() => import("@/components/admin/comic/comics"), {
  ssr: false,
});
const ComicFormContent = dynamic(
  () => import("@/components/admin/comic/form-comic"),
  {
    ssr: false,
  }
);
const ChaptersContent = dynamic(
  () => import("@/components/admin/comic/chapters"),
  {
    ssr: false,
  }
);
const ChapterFormContent = dynamic(
  () => import("@/components/admin/comic/form-chapter"),
  {
    ssr: false,
  }
);
const PagesContent = dynamic(() => import("@/components/admin/comic/pages"), {
  ssr: false,
});

export default function AdminPage() {
  const searchParams = useSearchParams();
  const view = searchParams.get("view") || "dashboard";

  // Function to get the component based on the view parameter
  const getComponent = () => {
    // Check view parameter and return the appropriate component
    switch (view) {
      case "comics-list":
        return <ComicsContent />;
      case "comics-form":
        return <ComicFormContent />;
      case "chapters-list":
        return <ChaptersContent />;
      case "chapter-form":
        return <ChapterFormContent />;
      case "pages-list":
        return <PagesContent />;
      default:
        return <DashboardContent />;
    }
  };

  return <AdminLayout>{getComponent()}</AdminLayout>;
}
