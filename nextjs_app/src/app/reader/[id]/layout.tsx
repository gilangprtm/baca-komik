import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'Pembaca Chapter', robots: { index: false, follow: true } };

export default function ReaderLayout({ children }: { children: React.ReactNode }) { return children; }
