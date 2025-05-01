"use client";

export default function DashboardContent() {
  return (
    <>
      <div className="grid auto-rows-min gap-4 md:grid-cols-3">
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <h3 className="text-xl font-semibold mb-2">Total Comics</h3>
          <p className="text-3xl font-bold">256</p>
        </div>
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <h3 className="text-xl font-semibold mb-2">Active Users</h3>
          <p className="text-3xl font-bold">1,289</p>
        </div>
        <div className="bg-muted/50 aspect-video rounded-xl p-6 flex flex-col">
          <h3 className="text-xl font-semibold mb-2">Total Views</h3>
          <p className="text-3xl font-bold">48,523</p>
        </div>
      </div>
      <div className="bg-muted/50 min-h-[400px] flex-1 rounded-xl p-6 md:min-h-min">
        <h2 className="text-2xl font-bold mb-4">Recent Activity</h2>
        <div className="space-y-4">
          <div className="p-4 bg-background rounded-lg">
            <p className="font-medium">
              New comic uploaded: One Piece Chapter 1102
            </p>
            <p className="text-sm text-muted-foreground">2 hours ago</p>
          </div>
          <div className="p-4 bg-background rounded-lg">
            <p className="font-medium">
              User report: Broken images on Jujutsu Kaisen Chapter 234
            </p>
            <p className="text-sm text-muted-foreground">5 hours ago</p>
          </div>
          <div className="p-4 bg-background rounded-lg">
            <p className="font-medium">
              New user registration spike: +125 users
            </p>
            <p className="text-sm text-muted-foreground">Yesterday</p>
          </div>
        </div>
      </div>
    </>
  );
}
