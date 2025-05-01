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
          url: "/admin?view=comics",
        },
        {
          title: "Add New",
          url: "/admin?view=comics-new",
        },
        {
          title: "Categories",
          url: "/admin?view=comics-categories",
        },
        {
          title: "Tags",
          url: "/admin?view=comics-tags",
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
          url: "/admin?view=chapters",
        },
        {
          title: "Upload",
          url: "/admin?view=chapters-upload",
        },
        {
          title: "Pending",
          url: "/admin?view=chapters-pending",
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
          url: "/admin?view=users",
        },
        {
          title: "Moderators",
          url: "/admin?view=users-moderators",
        },
        {
          title: "Banned Users",
          url: "/admin?view=users-banned",
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
          url: "/admin?view=reports-users",
        },
        {
          title: "Content Reports",
          url: "/admin?view=reports-content",
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
          url: "/admin?view=analytics",
        },
        {
          title: "Popular Comics",
          url: "/admin?view=analytics-popular",
        },
        {
          title: "User Activity",
          url: "/admin?view=analytics-users",
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
          url: "/admin?view=settings",
        },
        {
          title: "Appearance",
          url: "/admin?view=settings-appearance",
        },
        {
          title: "Storage",
          url: "/admin?view=settings-storage",
        },
      ],
    },
  ],
  projects: [
    {
      name: "Scheduled Uploads",
      url: "/admin?view=scheduled",
      icon: Clock,
    },
    {
      name: "Batch Uploader",
      url: "/admin?view=batch-upload",
      icon: Upload,
    },
    {
      name: "Tag Manager",
      url: "/admin?view=tag-manager",
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
