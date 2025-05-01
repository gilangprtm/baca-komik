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
      default:
        return <DashboardContent />;
    }
  };

  return <AdminLayout>{getComponent()}</AdminLayout>;
}
