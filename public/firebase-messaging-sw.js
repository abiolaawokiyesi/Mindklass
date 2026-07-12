/* MindKlass — Firebase Cloud Messaging service worker
 * Deploy this file at your site ROOT (e.g. https://yourdomain.com/firebase-messaging-sw.js)
 * so the browser can receive push notifications while the app is in the background
 * or closed. The config below MUST match FIREBASE_CONFIG in the app.
 */
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "YOUR_API_KEY",
  authDomain: "mindklass.firebaseapp.com",
  projectId: "mindklass",
  storageBucket: "mindklass.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
});

const messaging = firebase.messaging();

// Show a notification when a push arrives and the app is not in the foreground.
messaging.onBackgroundMessage(function (payload) {
  const n = payload.notification || {};
  self.registration.showNotification(n.title || "MindKlass", {
    body: n.body || "",
    icon: "/icon-192.png",
    badge: "/badge-72.png",
    data: payload.data || {},
  });
});

// Focus or open the app when the user taps the notification.
self.addEventListener("notificationclick", function (event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (list) {
      for (const c of list) {
        if ("focus" in c) return c.focus();
      }
      if (clients.openWindow) return clients.openWindow("/");
    })
  );
});
