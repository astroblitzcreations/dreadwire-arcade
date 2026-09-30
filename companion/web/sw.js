const C = "dreadwire-v25";
const A = [
  "/",
  "/static/app.css?v=23",
  "/static/controller-layout.css?v=15",
  "/static/app.js?v=25",
  "/static/icon.svg",
];
self.addEventListener("install", (event) =>
  event.waitUntil(
    caches
      .open(C)
      .then((cache) => cache.addAll(A))
      .then(() => self.skipWaiting()),
  ),
);
self.addEventListener("activate", (event) =>
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys.filter((key) => key !== C).map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  ),
);
self.addEventListener("fetch", (event) => {
  if (
    event.request.method === "GET" &&
    !event.request.url.includes("/api/") &&
    !event.request.url.includes("/ws/")
  ) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          const copy = response.clone();
          caches.open(C).then((cache) => cache.put(event.request, copy));
          return response;
        })
        .catch(() => caches.match(event.request)),
    );
  }
});
