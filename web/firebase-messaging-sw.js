importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyBEKOB-2y02I6gn6avWdPMlU9gdLaik9jU",
  authDomain: "supabase-messenger.firebaseapp.com",
  projectId: "supabase-messenger",
  storageBucket: "supabase-messenger.firebasestorage.app",
  messagingSenderId: "625963332142",
  appId: "1:625963332142:web:cf8c805afaf2bbb05965bf"
});

const messaging = firebase.messaging();
