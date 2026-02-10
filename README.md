# Flutter Messenger App

A modern, real-time messaging application built with **Flutter**, **Riverpod**, and **Supabase**, designed with a clean and professional UI inspired by popular messenger apps.

This project demonstrates practical, real-world Flutter skills including authentication, real-time UX updates, image messaging, state management, and scalable architecture.

##  Features

*  **Splash Screen** – Simple and professional entry experience
*  **Authentication** – Sign up & login using Supabase Auth
*  **Real-time Messaging UX** – Messages update instantly without manual refresh
*  **Text Messaging** – Send and receive messages smoothly
*  **Image Messaging** – Upload and send images in chat
*  **Search Functionality** – Search conversations or users
*  **Polished UI** – Clean, Messenger-style interface
*  **State Management with Riverpod** – Scalable and maintainable architecture
*  **Supabase Backend** – Database, auth, storage, and real-time logic
*  **FCM Integration (In Progress)** – Firebase Cloud Messaging setup attempted and prepared for Android notifications


##  Tech Stack

* **Flutter** (Frontend)
* **Riverpod** (State Management)
* **Supabase** (Auth, Database, Storage, Realtime)
* **Firebase Cloud Messaging** (Notification setup – partial)



##  Architecture & State Management

The app uses **Riverpod** to manage application state cleanly and predictably:

* `Provider` – Dependency injection (Supabase client, services)
* `StateProvider` – Lightweight UI state (search text, filters)
* `FutureProvider` / `FutureProvider.family` – Async data fetching (conversations, messages)
* `StateNotifier` – Business logic for authentication and actions

This separation ensures:

* Clean UI code
* Testable logic
* Predictable state updates


##  Notifications (FCM)

Firebase Cloud Messaging has been integrated at a setup level:

* FCM dependency included
* Token generation tested
* Android notification flow prepared

> Web push notifications were explored but not finalized due to platform limitations. The notification system is structured for easy extension in future versions.



## Limitations & Future Improvements

* Full background push notifications (FCM)
* Message seen/delivered status
* Group chats
* Voice messages
* Improved offline support



##  Purpose

This project was built as a **portfolio-quality Flutter application** to demonstrate:

* Real-time app development
* Clean architecture
* Modern state management
* Backend integration


##  Author

**Shafin**

Flutter Developer | Passionate about building scalable, real-world apps


##  Acknowledgements

* Flutter & Riverpod community
* Supabase documentation
* Firebase documentation


> Feel free to explore the code, run the app, or reach out for collaboration or feedback.

