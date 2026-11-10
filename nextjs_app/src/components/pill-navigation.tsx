'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Button } from '@/components/ui/button';

const items = [
  { label: 'Home', href: '/' },
  { label: 'Explore', href: '/search' },
  { label: 'Library', href: '/bookmarks' },
  { label: 'About', href: '/about' },
];

export function PillNavigation() {
  const pathname = usePathname();

  return (
    <nav className="nav-pill" aria-label="Navigasi utama">
      {items.map(({ label, href }) => {
        const active = href === '/' ? pathname === '/' : pathname === href || pathname.startsWith(`${href}/`);
        return (
          <Button key={href} render={<Link href={href} aria-current={active ? 'page' : undefined} />} variant="ghost" className="nav-link">
            {label}
          </Button>
        );
      })}
    </nav>
  );
}
