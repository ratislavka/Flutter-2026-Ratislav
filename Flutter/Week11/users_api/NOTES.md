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
