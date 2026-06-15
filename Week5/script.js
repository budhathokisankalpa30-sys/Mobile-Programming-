  // Import the functions you need from the SDKs you need
  import { initializeApp } from "https://www.gstatic.com/firebasejs/12.14.0/firebase-app.js";
  import { getDatabase } from "https://www.gstatic.com/firebasejs/12.14.0/firebase-database.js";
  // TODO: Add SDKs for Firebase products that you want to use
  // https://firebase.google.com/docs/web/setup#available-libraries

  // Your web app's Firebase configuration
  // For Firebase JS SDK v7.20.0 and later, measurementId is optional
  const firebaseConfig = {
    apiKey: "AIzaSyApdURMlzx2Fq421Wcqb8jDyO0CYw29puE",
    authDomain: "week-6-69409.firebaseapp.com",
    projectId: "week-6-69409",
    storageBucket: "week-6-69409.firebasestorage.app",
    messagingSenderId: "803201564979",
    appId: "1:803201564979:web:4f4a78a7448d9855af7e46",
    measurementId: "G-717E33C87Z"
  };

  // Initialize Firebase
  const app = initializeApp(firebaseConfig);
  const db = getDatabase(app);
console.log(db);