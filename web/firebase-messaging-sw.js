/* Firebase Cloud Messaging service worker (compat).
 * Config is loaded from firebase-config.json (written at deploy / local setup).
 * Do not put secrets in this file.
 */
importScripts(
  "https://www.gstatic.com/firebasejs/12.18.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/12.18.0/firebase-messaging-compat.js"
);

self.addEventListener("install", function (event) {
  self.skipWaiting();
});

self.addEventListener("activate", function (event) {
  event.waitUntil(self.clients.claim());
});

fetch("./firebase-config.json")
  .then(function (res) {
    if (!res.ok) {
      throw new Error("firebase-config.json HTTP " + res.status);
    }
    return res.json();
  })
  .then(function (config) {
    firebase.initializeApp(config);
    var messaging = firebase.messaging();
    // Defining onBackgroundMessage means we MUST show the notification ourselves.
    messaging.onBackgroundMessage(function (payload) {
      console.log("[firebase-messaging-sw] onBackgroundMessage", payload);
      var data = (payload && payload.notification) || {};
      var title = data.title || "Tổ Ấm";
      var options = {
        body: data.body || "",
        icon: "icons/Icon-192.png",
        data: (payload && payload.data) || {},
      };
      return self.registration.showNotification(title, options);
    });
  })
  .catch(function (err) {
    console.warn("[firebase-messaging-sw] init skipped:", err);
  });
