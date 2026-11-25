# Practice 11 · A Real Server

Open the iPhone Simulator from Xcode. In Terminal, from this folder, run:

```sh
flutter pub get
flutter run
```

The app loads users from JSONPlaceholder. Tap a user for details, pull down to refresh, or tap **New user** to open the form. You can open the form from the Offline screen. Save needs a connection and keeps your entries if the request fails.

For the handout's console demo, run:

```sh
flutter run --dart-define=RUN_LAB_CHECKS=true
```

**How to explain it:** `ApiClient` sends the HTTP request and checks its status. `UserRepository` turns the JSON into `User` objects. `UsersModel` keeps track of the users, loading and errors. The screen watches the model and shows the matching view. A failed connection and a ten-second timeout both lead to **Offline**.

[NOTES.md](NOTES.md) includes the API field tables, the Postman requests and the remaining live device checks. If the API fails in Simulator Safari, run `curl -i --max-time 15 https://jsonplaceholder.typicode.com/users` in Mac Terminal. If it fails there too, connect the Mac to a phone hotspot using mobile data and retry. If curl succeeds while the app fails, open **DevTools → Logging** and look for the `api` entry after pressing **Retry**.
