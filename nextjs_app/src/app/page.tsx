import { getEnvelope, type Manga } from '@/lib/api';
import HomeFeed from './home-feed';
import { Alert, AlertDescription } from '@/components/ui/alert';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { LoadingCards } from '@/components/infinite-loading';
import { Suspense } from 'react';

async function InitialHome() {
  try {
    const response = await getEnvelope<Manga[]>('/manga/list?page=1&page_size=24&is_update=true&sort=latest');
    return <HomeFeed initialItems={response.data} meta={response.meta} />;
  } catch (e) {
    return <Alert variant="destructive"><AlertDescription>{e instanceof Error ? e.message : 'Unable to load catalog'} <Button variant="outline" render={<Link href="/"/>}>Coba lagi</Button></AlertDescription></Alert>;
  }
}

export default function Home() {
  return <Suspense fallback={<LoadingCards label="Memuat katalog"/>}><InitialHome/></Suspense>;
}
