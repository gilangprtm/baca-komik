"use client";

import { useSearchParams } from "next/navigation";
import { Suspense } from "react";
import dynamic from "next/dynamic";
import { AdminLayout } from "@/components/admin-layout";

// Dynamically load components with loading state
const DashboardContent = dynamic(() => import("@/components/admin/dashboard"), {
  ssr: false,
  loading: () => <div>Loading dashboard...</div>,
});

const ComicsContent = dynamic(() => import("@/components/admin/comic/comics"), {
  ssr: false,
  loading: () => <div>Loading comics...</div>,
});

const ComicFormContent = dynamic(
  () => import("@/components/admin/comic/form-comic"),
  {
    ssr: false,
    loading: () => <div>Loading comic form...</div>,
  }
);

const ChaptersContent = dynamic(
  () => import("@/components/admin/comic/chapters"),
  {
    ssr: false,
    loading: () => <div>Loading chapters...</div>,
  }
);

const ChapterFormContent = dynamic(
  () => import("@/components/admin/comic/form-chapter"),
  {
    ssr: false,
    loading: () => <div>Loading chapter form...</div>,
  }
);

const PagesContent = dynamic(() => import("@/components/admin/comic/pages"), {
  ssr: false,
  loading: () => <div>Loading pages...</div>,
});

const MetadataContent = dynamic(
  () => import("@/components/admin/comic/metadata"),
  {
    ssr: false,
    loading: () => <div>Loading metadata...</div>,
  }
);

const FeaturedContent = dynamic(
  () => import("@/components/admin/comic/featured"),
  {
    ssr: false,
    loading: () => <div>Loading featured...</div>,
  }
);

const AnalyticsContent = dynamic(
  () => import("@/components/admin/analytics/overview"),
  {
    ssr: false,
    loading: () => <div>Loading analytics...</div>,
  }
);

const EngagementContent = dynamic(
  () => import("@/components/admin/analytics/engagement"),
  {
    ssr: false,
    loading: () => <div>Loading engagement...</div>,
  }
);

function AdminRouter() {
  const searchParams = useSearchParams();
  const view = searchParams.get("view") || "dashboard";

  // Get the component to render based on the view param
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
    case "metadata":
      return <MetadataContent />;
    case "featured":
      return <FeaturedContent />;
    case "analytics-overview":
      return <AnalyticsContent />;
    case "analytics-engagement":
      return <EngagementContent />;
    default:
      return <DashboardContent />;
  }
}

function AdminDashboardContent() {
  return (
    <Suspense fallback={<div>Loading admin dashboard...</div>}>
      <AdminRouter />
    </Suspense>
  );
}

// Default export for dynamic import
export default function AdminDashboardWrapper() {
  return (
    <AdminLayout>
      <AdminDashboardContent />
    </AdminLayout>
  );
}

// Named export for direct import
export function AdminDashboard() {
  return <AdminDashboardContent />;
}
