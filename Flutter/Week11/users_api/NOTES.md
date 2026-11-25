# Practice 12 · Survive a Restart

## Package review, 25 November 2026

Counts below are repository-wide open issues including pull requests, while commit dates refer to the package directory. “All six” means Android, iOS, Linux, macOS, web and Windows.

- [shared_preferences](https://pub.dev/packages/shared_preferences) from verified publisher flutter.dev released in October 2026, supports all six, scores 160/160, has 315 open tracker entries with a commit on November 11, uses Flutter plus the platform interface and native/web preference adapters, and carries the BSD-3-Clause licence.
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) from verified publisher steenbakker.dev released in September 2026, supports all six, scores 160/160, has 27 open tracker entries with a commit on November 1, uses Flutter plus meta, its platform interface and Darwin, Linux, Windows and web adapters, and carries the BSD-3-Clause licence.
- [path_provider](https://pub.dev/packages/path_provider) from verified publisher flutter.dev released in June 2026, supports Android, iOS, Linux, macOS and Windows, scores 160/160, has 315 open tracker entries with a commit on November 11, uses Flutter plus the platform interface and filesystem adapters, and carries the BSD-3-Clause licence.
- [image_picker](https://pub.dev/packages/image_picker) from verified publisher flutter.dev released in October 2026, supports all six, scores 160/160, has 315 open tracker entries with a commit on November 24, uses Flutter plus the picker interface and platform adapters, and carries the BSD-3-Clause licence.
- [permission_handler](https://pub.dev/packages/permission_handler) from verified publisher baseflow.com released in September 2026, supports Android, iOS, web and Windows, scores 160/160, has 158 open tracker entries with a commit on November 3, uses Flutter plus meta, its interface and Android, Apple, HTML and Windows adapters, and carries the MIT licence.
- [url_launcher](https://pub.dev/packages/url_launcher) from verified publisher flutter.dev released in October 2026, supports all six, scores 160/160, has 315 open tracker entries with a commit on November 24, uses Flutter plus the launcher interface and six platform adapters, and carries the BSD-3-Clause licence.

## Resolution and storage

The six direct package constraints use carets. For example, `^1.2.0` accepts stable versions from 1.2.0 up to, but excluding, 2.0.0. It accepts 1.2.1 and 1.6.0 and refuses 1.1.9 and 2.0.0. The app commits pubspec.lock so another checkout uses the same exact direct and transitive versions.

With this package set, pinning `http: 1.2.0` failed resolution. That version needs `web <0.5.0`, while permission_handler_html needs `web >=0.5.1`. Restoring the caret resolved HTTP 1.6.0. Flutter pub outdated listed material_color_utilities 0.13.1 as newer than 0.13.0, which the Flutter SDK pins.

The app reads dark mode and city before runApp so the first frame uses the saved theme and filter. Preferences are suitable for these settings. A token in legacy Android preferences XML or an Apple preferences plist could be recovered from an accessible backup, a rooted device, or a computer with privileged access over a cable. The newer Android preferences backend can use DataStore, which also provides no secret-storage guarantee.

The fake login saves its bearer token in secure storage. iOS Keychain entries can survive uninstall and reinstall. On Android, removing the secure lock screen can invalidate authentication-bound Keystore keys, requiring a fresh login. The users file and avatar live in Documents because the OS may purge Temporary at any time.

## Permission behaviour

On Android, deny the first camera prompt and tap Take photo again. After repeated denials (typically two on Android 11+), the OS stops prompting and the app offers Open settings. On iOS a single camera denial is enough. Later requests require changing the permission in Settings. Photos also has a limited-access state, in which only selected photos are visible. Cancelling the picker keeps the existing avatar.

The two screenshots come from Flutter widget tests using a cached user fixture and a simulated permanent camera denial.

# Practice 11 · A Real Server

## Level 1 · API inspection

Base URL: `https://jsonplaceholder.typicode.com`.

| Request | Status | Content-Type and response |
| --- | --- | --- |
| `GET /users` | 200 | `application/json`, array of 10 user objects |
| `GET /users/1` | 200 | `application/json`, one user object, Leanne Graham |
| `GET /users/999` | 404 | Expected JSON body `{}` |
| `GET /users?id=3` | Expected 200 | Expected JSON array with one object, user 3 |
| `POST /users` | Expected 201 | Expected JSON response echoes the submitted fields and adds the server-assigned `id: 11` |

The public endpoint returned the user list and user 1 through an external HTTP check, which also confirmed the 404 status. The local connection failed DNS resolution. The 404 body, the filtered GET and POST outcomes above come from the handout and still need a live Postman or curl check. JSONPlaceholder simulates writes, so refreshing retrieves the original list.

For Postman, enter the GET URLs from the table. For POST, use `/users`, choose **Body → raw → JSON**, and send this body. Postman sets `Content-Type: application/json` when you choose JSON.

```json
{"name":"Practice Student","username":"practice11","email":"student@example.com"}
```

### User

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| id | Integer number | `int` | No |
| name | String | `String` | No |
| username | String | `String` | No |
| email | String | `String` | No |
| address | Object | `Address` | No |
| phone | String | `String` | No |
| website | String | `String?` | Yes, also allowed to be missing |
| company | Object | `({String name, String catchPhrase})` plus `companyBs` | No |

### Address

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| street | String | `String` | No |
| suite | String | `String` | No |
| city | String | `String` | No |
| zipcode | String | `String` | No |
| geo | Object nested inside address | `Geo` | No |

### Address.geo

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| lat | String | `double` via `double.parse` | No |
| lng | String | `double` via `double.parse` | No |

### Company

| Field | JSON type | Dart type | Nullable? |
| --- | --- | --- | --- |
| name | String | `String` | No |
| catchPhrase | String | `String` | No |
| bs | String | `String` on `User.companyBs` | No |

The sample includes `website`. The app still accepts an absent or null website, as required. It keeps `company.bs` separately so the record has the exact two fields required by the handout and the JSON round-trip retains all keys.

## Levels 2–4 · Console and app checks

- To run the console checks before the app opens, use `flutter run --dart-define=RUN_LAB_CHECKS=true`. It parses the original user 1 JSON, prints all the names, catches the 404 and prints `not found`, then prints the ID from the POST.
- The three-field form fills the other required user fields with empty values. The POST omits the draft ID so the response can supply it.
- `grep -rn "package:http" lib/` reports only `api_client.dart` and `user_repository.dart`. The client type alias lets `main.dart` construct the injected client with those two imports.
- To try the typo in Level 4, pass `host: 'jsonplaceholder.typicode.co'` to `ApiClient` in `main.dart` and hot restart. Restore the correct host and hot restart, since hot reload retains the client instance. Use Retry with the correct host when connectivity returns.

- For the parsing experiment, temporarily replace the latitude parse with `json['lat'] as double`, or change the demo JSON's `"id": 1` to `"id": "1"`. Run the console demo, observe the type error, then undo the change.
- For the error-switch experiment, temporarily remove the `BadResponseException` arm in `users_screen.dart` and run `flutter analyze`. Restore it after seeing the exhaustiveness error.

## Level 5 · Live device evidence

| Test | Expected behavior | Measured on device |
| --- | --- | --- |
| Airplane mode | Offline view quickly, typically within a second | Pending |
| Hotspot without internet | Same Offline view after about 10 seconds if the request receives no immediate network error | Pending |

With controlled HTTP responses, the repository converted an immediate socket failure in under 1 ms and a stalled request in 10.003 s to `NoConnectionException`. The table above is for the separate live device measurements.

1. On a phone or emulator with network controls, run the app and open **DevTools → Network**. Start recording before refreshing.
2. With working internet, pull down to refresh, open the `GET /users` row for status 200 and show its response body. Save `screenshot_200.png` beside this file.
3. Enable airplane mode and pull to refresh. Time how long the Offline view takes. Restore the connection and tap **Retry**.
4. Connect to a hotspot without internet, then pull to refresh and time when Offline appears. Capture the `/users` request with no status after ten seconds as `screenshot_timeout.png`. If the network rejects the request immediately, use a hotspot that keeps the network connected while the request stalls.
5. Restore connectivity, tap **Retry**, submit **New user** once, and check that DevTools shows one POST with status 201. The form closes and the user appears first in the list.
