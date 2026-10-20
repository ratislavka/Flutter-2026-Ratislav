# Cinema Club - Movie Screenings 

**Domain:** Indie Cinema & Watch Party Club (`Screening`). Members browse theatrical screenings and online synchronized watch parties, filter by film genre, and book or cancel seats against hall capacity.

## Screenshots
- Phone Light: `screenshots/phone_light.png`
- Phone Dark: `screenshots/phone_dark.png`
- Tablet Grid: `screenshots/tablet_grid.png`

## Decisions
1. **Where the list lives:** The master `List<Screening>` and `Profile` state live in `_ShellScreenState` so that all three tabs (`ListTab`, `FavouritesTab`, and `ProfileTab`) read from a single source of truth and propagate mutations upward via callbacks.
2. **Why Detail takes callbacks and Form returns a value:** `DetailScreen` stays open while the user books a seat, cancels a booking, or edits the screening, so it needs callbacks (`onUpdated`, `onDeleted`, `onSwitchToProfile`) to synchronize live changes with the shell immediately, whereas `FormScreen` represents a single transactional creation or edit that resolves once by returning a `Screening?` via `Navigator.pop`.
3. **Why the grid uses `LayoutBuilder`:** `LayoutBuilder` branches on the parent widget's actual incoming `BoxConstraints` (`maxWidth >= 600`) rather than the global window size from `MediaQuery`, ensuring the layout adapts accurately even inside split views or constrained containers.
4. **What `PopScope` compares:** `PopScope` computes `_isDirty` by comparing the current controller texts, selected genre, stream mode flag, and combined date/time against the initial `Screening` values the form opened with, blocking silent back navigation only when unsaved edits exist and while `_isSaving` is active.
5. **What I would change with Week 9's tools:** With Week 9's state management (`Provider` / `ChangeNotifier` or `Riverpod`), I would move `_screenings`, `_profile`, and `_themeMode` out of `_ShellScreenState` and `_MyAppState` into a dedicated notifier so deeply nested screens like `DetailScreen` and `ProfileTab` can read and mutate state directly without prop-drilling callbacks through constructors and route arguments.