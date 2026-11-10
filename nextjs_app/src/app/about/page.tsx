import { Card, CardContent } from '@/components/ui/card';

export default function AboutPage() {
  return (
    <Card>
      <CardContent>
        <article>
          <p>BacaKomik membantu Anda menjelajahi katalog dan membaca komik.</p>
          <p>Bookmark dan riwayat bacaan disimpan di browser ini. Katalog dan halaman bab memerlukan koneksi internet.</p>
          <p>Saat offline, yang tersedia hanya shell aplikasi; membaca katalog dan bab secara offline tidak dijamin. Konten komik disediakan oleh sumber upstream, bukan oleh BacaKomik.</p>
        </article>
      </CardContent>
    </Card>
  );
}
