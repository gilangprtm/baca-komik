const CACHE='bacakomik-shell-v1';
self.addEventListener('install',event=>{event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(['/','/manifest.json','/offline.html'])))});
self.addEventListener('activate',event=>{event.waitUntil(self.clients.claim())});
self.addEventListener('fetch',event=>{
 const url=new URL(event.request.url);
 if(event.request.method!=='GET'||url.pathname.startsWith('/api/')||url.origin!==self.location.origin)return;
 event.respondWith(fetch(event.request).then(response=>{
   if(response.ok&&event.request.mode==='navigate')caches.open(CACHE).then(cache=>cache.put(event.request,response.clone()));
   return response;
 }).catch(async()=>{
   const cache=await caches.open(CACHE);
   return (await cache.match(event.request))||(event.request.mode==='navigate'?cache.match('/offline.html'):Response.error());
 }));
});
