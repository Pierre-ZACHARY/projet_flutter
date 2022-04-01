importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBt4sj_EFJNzIoAyG5QS5yI6BAcr9wnsp0",
    authDomain: "projet-flutter-35bae.firebaseapp.com",
    projectId: "projet-flutter-35bae",
    storageBucket: "projet-flutter-35bae.appspot.com",
    messagingSenderId: "143286365004",
    appId: "1:143286365004:web:ade441aa407f8206d53de9",
    measurementId: "G-WHGXE62Y3Q"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});