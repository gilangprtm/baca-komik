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
} from "lucide-react";

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

// This is sample data for BacaKomik admin
const data = {
  user: {
    name: "Admin",
    email: "admin@bacakomik.com",
    avatar: "/avatars/admin.jpg",
  },
  teams: [
    {
      name: "BacaKomik",
      logo: BookOpen,
      plan: "Admin",
    },
  ],
  navMain: [
    {
      title: "Dashboard",
      url: "/admin",
      icon: Home,
      isActive: true,
      items: [],
    },
    {
      title: "Comics",
      url: "#",
      icon: BookOpen,
      items: [
        {
          title: "All Comics",
          url: "/admin/comics",
        },
        {
          title: "Add New",
          url: "/admin/comics/new",
        },
        {
          title: "Categories",
          url: "/admin/comics/categories",
        },
        {
          title: "Tags",
          url: "/admin/comics/tags",
        },
      ],
    },
    {
      title: "Chapters",
      url: "#",
      icon: List,
      items: [
        {
          title: "All Chapters",
          url: "/admin/chapters",
        },
        {
          title: "Upload",
          url: "/admin/chapters/upload",
        },
        {
          title: "Pending",
          url: "/admin/chapters/pending",
        },
      ],
    },
    {
      title: "User Management",
      url: "#",
      icon: Users,
      items: [
        {
          title: "All Users",
          url: "/admin/users",
        },
        {
          title: "Moderators",
          url: "/admin/users/moderators",
        },
        {
          title: "Banned Users",
          url: "/admin/users/banned",
        },
      ],
    },
    {
      title: "Reports",
      url: "#",
      icon: ShieldAlert,
      items: [
        {
          title: "User Reports",
          url: "/admin/reports/users",
        },
        {
          title: "Content Reports",
          url: "/admin/reports/content",
        },
      ],
    },
    {
      title: "Analytics",
      url: "#",
      icon: BarChart3,
      items: [
        {
          title: "Overview",
          url: "/admin/analytics",
        },
        {
          title: "Popular Comics",
          url: "/admin/analytics/popular",
        },
        {
          title: "User Activity",
          url: "/admin/analytics/users",
        },
      ],
    },
    {
      title: "Settings",
      url: "#",
      icon: Settings2,
      items: [
        {
          title: "General",
          url: "/admin/settings",
        },
        {
          title: "Appearance",
          url: "/admin/settings/appearance",
        },
        {
          title: "Storage",
          url: "/admin/settings/storage",
        },
      ],
    },
  ],
  projects: [
    {
      name: "Scheduled Uploads",
      url: "/admin/scheduled",
      icon: Clock,
    },
    {
      name: "Batch Uploader",
      url: "/admin/batch-upload",
      icon: Upload,
    },
    {
      name: "Tag Manager",
      url: "/admin/tag-manager",
      icon: Tag,
    },
  ],
};

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  return (
    <Sidebar collapsible="icon" {...props}>
      <SidebarHeader>
        <TeamSwitcher teams={data.teams} />
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={data.navMain} />
        <NavProjects projects={data.projects} />
      </SidebarContent>
      <SidebarFooter>
        <NavUser user={data.user} />
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  );
}
