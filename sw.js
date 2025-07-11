const CACHE_NAME = 'imyashvinder-v3';
const CACHE_VERSION = '3';
const urlsToCache = [
  '/',
  '/blog/',
  'https://raw.githubusercontent.com/imyashvinder/imyashvinder.github.io/main/profile-small.png'
];

// Add timestamp to force cache updates
const CACHE_TIMESTAMP = Date.now();

self.addEventListener('install', event => {
  console.log('Service Worker installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Caching app shell');
        return cache.addAll(urlsToCache);
      })
      .then(() => {
        console.log('Service Worker installed');
        return self.skipWaiting();
      })
  );
});

self.addEventListener('fetch', event => {
  // Only handle GET requests
  if (event.request.method !== 'GET') {
    return;
  }

  // Skip non-HTTP requests
  if (!event.request.url.startsWith('http')) {
    return;
  }

  // Only handle requests to our own domain
  const url = new URL(event.request.url);
  if (url.hostname !== 'imyashvinder.github.io') {
    return;
  }

  // Skip external CDN resources
  if (event.request.url.includes('maxcdn.bootstrapcdn.com') ||
      event.request.url.includes('ajax.googleapis.com') ||
      event.request.url.includes('googletagmanager.com') ||
      event.request.url.includes('google-analytics.com')) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request).catch(() => {
          // If fetch fails, return a basic response
          return new Response('', { status: 404 });
        });
      })
  );
});

self.addEventListener('activate', event => {
  console.log('Service Worker activating...');
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker activated');
      return self.clients.claim();
    })
  );
}); 