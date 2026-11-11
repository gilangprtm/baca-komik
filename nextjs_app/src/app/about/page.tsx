import { Card, CardContent } from '@/components/ui/card';
import { Heart } from 'lucide-react';
import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'Tentang BacaKomik', description: 'Informasi tentang BacaKomik, katalog komik, bookmark, riwayat bacaan, dan dukungan.' };

export default function AboutPage() {
  return (
    <Card>
      <CardContent>
        <article>
          <p>BacaKomik membantu Anda menjelajahi katalog dan membaca komik.</p>
          <p>Bookmark dan riwayat bacaan disimpan di browser ini. Katalog dan halaman bab memerlukan koneksi internet.</p>
          <p>Saat offline, yang tersedia hanya shell aplikasi; membaca katalog dan bab secara offline tidak dijamin. Konten komik disediakan oleh sumber upstream, bukan oleh BacaKomik.</p>
          <a href="https://saweria.co/playbit" target="_blank" rel="noopener noreferrer" className="mt-6 inline-flex min-h-12 items-center justify-center gap-2 rounded-xl bg-[#7136ed] px-6 py-3 font-semibold text-white transition-colors hover:bg-[#8251f4] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#b59aff]" aria-label="Donasi melalui Saweria (buka tab baru)"><Heart className="size-5" aria-hidden="true"/>Donasi</a>
        </article>
      </CardContent>
    </Card>
  );
}
