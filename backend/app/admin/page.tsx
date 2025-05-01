"use client";

import { useSearchParams } from "next/navigation";
import { AdminLayout } from "@/components/admin-layout";
import dynamic from "next/dynamic";

// Komponen-komponen yang akan dimuat secara dinamis
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
  const searchParams = useSearchParams();
  const view = searchParams.get("view") || "dashboard";

  // Fungsi untuk mendapatkan komponen berdasarkan parameter view
  const getComponent = () => {
    // Cek parameter view dan kembalikan komponen yang sesuai
    switch (view) {
      case "comics":
        return <ComicsContent />;
      case "comics-new":
        return <NewComicContent />;
      default:
        return <DashboardContent />;
    }
  };

  return <AdminLayout>{getComponent()}</AdminLayout>;
}
