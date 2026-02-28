'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "d8381fe1ade80d7ad808ee675411bbec",
"version.json": "df160da147cad14f3f45d65c3d49cca0",
"splash/img/light-2x.png": "b35ec26b788c9c3970edaa202a9e3f13",
"splash/img/dark-4x.png": "18c1632c71c4106680fc694ce9f2dd5e",
"splash/img/light-3x.png": "1bd6d16134e32a9f474716c01568f930",
"splash/img/dark-3x.png": "1bd6d16134e32a9f474716c01568f930",
"splash/img/light-4x.png": "18c1632c71c4106680fc694ce9f2dd5e",
"splash/img/dark-2x.png": "b35ec26b788c9c3970edaa202a9e3f13",
"splash/img/dark-1x.png": "f25325ce0236d320821eec36d18cc81a",
"splash/img/light-1x.png": "f25325ce0236d320821eec36d18cc81a",
"index.html": "2429e95f30d7d93e1b8718bd0684fdc3",
"/": "2429e95f30d7d93e1b8718bd0684fdc3",
"main.dart.js": "7c152fe53db682ace3bb296c748eb315",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "8dbdc74c5160cc4e4c334a86de411010",
"icons/Icon-192.png": "80185dae78bbe73e07d883e264d129d2",
"icons/Icon-maskable-192.png": "80185dae78bbe73e07d883e264d129d2",
"icons/Icon-maskable-512.png": "b35ec26b788c9c3970edaa202a9e3f13",
"icons/Icon-512.png": "b35ec26b788c9c3970edaa202a9e3f13",
"manifest.json": "bbdfd26ebce4f9e8a9b50099580cbadb",
"assets/NOTICES": "dfd59b9ac6d616b5357fd6186066f514",
"assets/FontManifest.json": "722633f3609b1e214ead7c624fcfde5c",
"assets/AssetManifest.bin.json": "094298af93e3e1cf4965a214743eafe3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "9b2a38c5e1b7576103255272b0b3ca93",
"assets/fonts/MaterialIcons-Regular.otf": "4d7eb1069e208dec8a2cee9c8b0ca85a",
"assets/assets/icon.png": "962d9188e28f162654b557b3a7e9c582",
"assets/assets/splash.png": "962d9188e28f162654b557b3a7e9c582",
"assets/assets/audio/music/Main_BGM.wav": "b676aa73cafe95d4759af1cca7b060b4",
"assets/assets/audio/music/Menu_BGM.wav": "232ae559aceba8d4a36afa784ab41fba",
"assets/assets/audio/sfx/Start.mp3": "30eda6e67136c7f86cc385981da39211",
"assets/assets/audio/sfx/Fail.mp3": "39d8212d0f4b548a3e6e8ee4d5d44abb",
"assets/assets/audio/sfx/TimeTic.mp3": "019e5009782ddde339c5e97eded036fe",
"assets/assets/audio/sfx/Clear.mp3": "048be116ce3c358449235253905444de",
"assets/assets/audio/sfx/BtnSnd.mp3": "d452fb8c38e3698fe64d27cd62cde31a",
"assets/assets/audio/sfx/Collect.mp3": "081f70f4227a756d5b3e491e060e9f7e",
"assets/assets/fonts/HU%25E1%2584%258B%25E1%2585%25A2%25E1%2586%25BC%25E1%2584%2583%25E1%2585%25AE%25E1%2584%258B%25E1%2585%25B5%25E1%2586%25B8%25E1%2584%2589%25E1%2585%25AE%25E1%2586%25AF140.otf": "cb140363bfe3e27679e6f24e5586a6be",
"assets/assets/fonts/HU%25EC%2595%25B5%25EB%2591%2590%25EC%259E%2585%25EC%2588%25A0140.otf": "cb140363bfe3e27679e6f24e5586a6be",
"assets/assets/translations/ja.json": "f4e0ae663a0945bd6a09b1b2c3f3265f",
"assets/assets/translations/zh-CN.json": "5cbb32d0d136f1508407ac2ee7771653",
"assets/assets/translations/en.json": "c59a9e8e821a3d74ebb815851ecedd1b",
"assets/assets/translations/ko.json": "bf2f0e71093c1a8b55b103454d37c0f5",
"assets/assets/translations/zh-TW.json": "0798d07796edd8dcfcdfa50971801706",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
