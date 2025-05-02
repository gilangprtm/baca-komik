"use client";

import dynamic from "next/dynamic";

// Disable SSR for the entire admin section
const AdminDashboardNoSSR = dynamic(
  () => import("@/components/admin/admin-dashboard"),
  { ssr: false, loading: () => <div>Loading admin panel...</div> }
);

export default function AdminPage() {
  return <AdminDashboardNoSSR />;
}
