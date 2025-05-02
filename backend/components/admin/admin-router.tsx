"use client";

import { useSearchParams } from "next/navigation";
import { Suspense, ComponentType } from "react";

interface AdminRouterProps {
  routes: {
    [key: string]: ComponentType;
  };
  defaultRoute: string;
}

export default function AdminRouter({
  routes,
  defaultRoute,
}: AdminRouterProps) {
  // Wrap the component that uses useSearchParams in a client component with Suspense
  return (
    <Suspense fallback={<div>Loading router...</div>}>
      <AdminRouterContent routes={routes} defaultRoute={defaultRoute} />
    </Suspense>
  );
}

function AdminRouterContent({ routes, defaultRoute }: AdminRouterProps) {
  const searchParams = useSearchParams();
  const view = searchParams.get("view") || defaultRoute;

  // Get the component to render based on the view param
  const Component = routes[view] || routes[defaultRoute];

  return <Component />;
}
