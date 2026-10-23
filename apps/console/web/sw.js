// WaterCheck web app shell (ADR-022): installable and opens offline.
//
// Network first, so a new release is used as soon as it is online; the
// last copy of each app file is kept for when there is no connection.
// Only this app's own files are handled: the API, map tiles and routes
// (outside this folder) always go to the network.
const CACHE = 'watercheck-shell-v1';
// Not the app's files, though under this scope (the Console is served at
// the site root, next to these).
const SKIP = ['api/', 'tiles/', 'route/', 'collect/', 'health'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(['./', 'index.html'])),
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(
        keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)),
      ))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const scope = self.registration.scope;
  if (!request.url.startsWith(scope)) return;
  const path = request.url.slice(scope.length);
  if (SKIP.some((p) => path.startsWith(p))) return;
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(() =>
        caches.match(request).then(
          (hit) => hit || caches.match('index.html'),
        ),
      ),
  );
});
