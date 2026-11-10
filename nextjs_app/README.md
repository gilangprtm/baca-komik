# BacaKomik Next.js PWA

Independent app port, using Shinigami GET API (`https://api.shngm.io/v1`) via same-origin Next rewrites. Install with `npm install`, run `npm run dev`, validate with `npm run lint`, `npm test`, and `npm run build`.

Routes: `/` catalog, `/search`, `/bookmarks` (IndexedDB bookmarks/history), `/profile`, `/comic/[id]`, `/reader/[id]`. PWA app shell fallback only; remote API and chapter pages are not cached. Data retention is local to this browser. API availability/CORS are mediated by Next rewrites.
