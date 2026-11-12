
# Practice 10 — The Data Arrives Later

## Level 1: Event Loop

### Predicted order

A
C
B
6 students

### Expected actual order

A
C
fetchStudents #1
B
6 students

### Explanation

Future.delayed does not block the event loop.

The code continues executing while the Future
waits for its completion.

When fetchStudents() is called three times using
the same FakeApi instance, the third request fails.

Expected error:

Unhandled Exception:
Instance of 'NoConnectionException'

### Blocking the event loop

Replacing Future.delayed with sleep() blocks
the main isolate.

As a result, the application cannot render
its first frame until the blocking operations finish.

The original Future.delayed was restored.


## Level 2: Manual State Management

The screen has four states:

1. Loading
2. Error
3. Empty
4. Data

The API request is started in initState().

The result is handled using try/catch.

Without the mounted checks, leaving the screen
before the request completes can produce:

setState() called after dispose()

Restoring the mounted checks prevents this error.


## Level 3: FutureBuilder

FutureBuilder manages asynchronous state using
an AsyncSnapshot.

The Future is stored in a field and created
once in initState().

Changing the Compact Switch does not
start additional API requests.

When fetchStudents() is called directly inside
build(), switching Compact triggers another request.

The correct implementation uses:

future: _future

An empty successful response displays
"No students yet" instead of a loading spinner.


## Level 4: Countdown

### Version A: StreamBuilder

The countdown starts at 10 and finishes at 0.

When leaving the screen, StreamBuilder
automatically cancels its subscription.

No additional ticks appear in the console.


### Version B: StreamSubscription

The manual subscription is created using listen().

When _sub.cancel() is called in dispose(),
the countdown stops after leaving the screen.

Without cancel(), the subscription continues
receiving events.

Expected error:

setState() called after dispose()

The console continues printing ticks
even though the screen was removed.

Restoring cancel() fixes the problem.


## Level 5: Save Errors

### Incorrect implementation

The save() Future was called without await.

The application immediately navigated back.

When the server rejected the second request,
the user still saw the screen close.

Expected console error:

Unhandled Exception:
Bad state: server rejected 6


### Correct implementation

The save operation is awaited.

try/on StateError handles failures.

The application navigates back only after
a successful save.

On failure, a Snackbar displays the error.

context.mounted is checked after await.

A boolean _saving prevents multiple requests
from rapid button presses.

The Save button displays a spinner while saving.


## Final verification

Complete these checks after running the app:

- [ ] Three home screen buttons work
- [ ] Four states display correctly
- [ ] FutureBuilder Switch does not reload
- [ ] Countdown subscriptions stop correctly
- [ ] Save errors are handled
- [ ] No analyzer issues
- [ ] Screenshots captured
- [ ] Changes pushed to GitHub
