"use client";

import dynamic from "next/dynamic";
import { SPARouter } from "@/components/spa-router";

// Use dynamic imports to avoid NextJS pre-rendering these components
const DashboardContent = dynamic(() => import("@/components/admin/dashboard"), {
  ssr: false,
});
const ComicsContent = dynamic(() => import("@/components/admin/comics"), {
  ssr: false,
});
const NewComicContent = dynamic(() => import("@/components/admin/new-comic"), {
  ssr: false,
});

export default function AdminPage() {
  // Define our SPA routes
  const routes = [
    {
      path: "/admin",
      component: <DashboardContent />,
    },
    {
      path: "/admin/comics",
      component: <ComicsContent />,
    },
    {
      path: "/admin/comics/new",
      component: <NewComicContent />,
    },
    // Add other routes here as needed
  ];

  return <SPARouter routes={routes} />;
}
