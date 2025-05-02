import ComicList from "./components/ComicList";

export default function Home() {
  return (
    <div className="container mx-auto px-4 py-8">
      <header className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Baca Komik</h1>
        <p className="text-gray-600">Baca komik kesukaan kamu</p>
      </header>

      <main>
        <section className="mb-8">
          <h2 className="text-xl font-semibold mb-4">Top Comics</h2>
          <ComicList />
        </section>
      </main>
    </div>
  );
}
