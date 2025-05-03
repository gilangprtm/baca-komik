"use client";

import * as React from "react";
import {
  BarChart3,
  BookOpen,
  Users,
  Tag,
  Settings2,
  Upload,
  List,
  Clock,
  ShieldAlert,
  Home,
  Flame,
  PenTool,
  BookMarked,
  Layers,
  FileText,
} from "lucide-react";
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs";

import { NavMain } from "@/components/nav-main";
import { NavProjects } from "@/components/nav-projects";
import { NavUser } from "@/components/nav-user";
import { TeamSwitcher } from "@/components/team-switcher";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarRail,
} from "@/components/ui/sidebar";
import { Database } from "@/lib/supabase/database.types";

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const supabase = createClientComponentClient<Database>();
  const [userData, setUserData] = React.useState({
    name: "Admin",
    email: "",
    avatar: "",
  });
  const [activeNavItem, setActiveNavItem] = React.useState("dashboard");
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    async function fetchUserData() {
      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (user) {
          setUserData({
            name: "Admin",
            email: user.email || "",
            avatar: "",
          });
        }
      } catch (error) {
        console.error("Error fetching user:", error);
      } finally {
        setLoading(false);
      }
    }

    fetchUserData();
  }, [supabase]);

  // Set active nav item based on current path
  React.useEffect(() => {
    if (typeof window !== "undefined") {
      const path = window.location.pathname;
      const viewParam = new URLSearchParams(window.location.search).get("view");

      if (path === "/admin" && !viewParam) {
        setActiveNavItem("dashboard");
      } else if (viewParam?.includes("comics")) {
        setActiveNavItem("comics");
      } else if (
        viewParam?.includes("chapter") ||
        viewParam?.includes("pages")
      ) {
        setActiveNavItem("chapters");
      } else if (viewParam?.includes("metadata")) {
        setActiveNavItem("metadata");
      } else if (viewParam?.includes("featured")) {
        setActiveNavItem("featured");
      } else if (viewParam?.includes("user")) {
        setActiveNavItem("users");
      } else if (viewParam?.includes("analytics")) {
        setActiveNavItem("analytics");
      } else if (viewParam?.includes("settings")) {
        setActiveNavItem("settings");
      }
    }
  }, []);

  const teams = [
    {
      name: "BacaKomik Admin",
      logo: BookOpen,
      plan: "Admin Dashboard",
    },
  ];

  const navMain = [
    {
      title: "Dashboard",
      url: "/admin",
      icon: Home,
      isActive: activeNavItem === "dashboard",
      items: [
        {
          title: "Dashboard",
          url: "/admin",
        },
      ],
    },
    {
      title: "Comic Management",
      url: "#",
      icon: BookOpen,
      isActive: activeNavItem === "comics",
      items: [
        {
          title: "All Comics",
          url: "/admin?view=comics-list",
        },
        {
          title: "Add New Comic",
          url: "/admin?view=comics-form",
        },
      ],
    },
    {
      title: "Featured Comics",
      url: "/admin?view=featured",
      icon: Flame,
      isActive: activeNavItem === "featured",
      items: [
        {
          title: "Manage Featured Comics",
          url: "/admin?view=featured",
        },
      ],
    },
    {
      title: "User Management",
      url: "#",
      icon: Users,
      isActive: activeNavItem === "users",
      items: [
        {
          title: "All Users",
          url: "/admin?view=users-list",
        },
        {
          title: "Comments Moderation",
          url: "/admin?view=users-comments",
        },
        {
          title: "Reports",
          url: "/admin?view=users-reports",
        },
      ],
    },
    {
      title: "Analytics",
      url: "#",
      icon: BarChart3,
      isActive: activeNavItem === "analytics",
      items: [
        {
          title: "Overview",
          url: "/admin?view=analytics-overview",
        },
        {
          title: "Popular Comics",
          url: "/admin?view=analytics-popular",
        },
        {
          title: "User Engagement",
          url: "/admin?view=analytics-engagement",
        },
      ],
    },
  ];

  const projects = [
    {
      title: "Settings",
      url: "#",
      icon: Settings2,
      isActive: activeNavItem === "settings",
      items: [
        {
          title: "API Configuration",
          url: "/admin?view=settings-api",
        },
        {
          title: "Admin Accounts",
          url: "/admin?view=settings-accounts",
        },
      ],
    },
  ];

  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <TeamSwitcher teams={teams} />
      </SidebarHeader>
      <SidebarContent>
        <NavMain title="Platform" items={navMain} />
        <NavMain title="..." items={projects} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={userData} />
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  );
}
