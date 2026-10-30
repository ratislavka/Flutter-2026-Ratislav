# Practice 9 Notes: Put It High, Subscribe Low

## Level 1: Lift It Up
- **Adding `total` to `CartBadge`:**
  - **Constructors touched:** 2 (`BooksScreen` and `CartBadge`, even though `BooksScreen` does not use `total` itself and only forwards it).
  - **Files modified:** 3 (`lib/main.dart`, `lib/books_screen.dart`, `lib/cart_badge.dart`).
- **Console lines printed on a single "Add" tap:**
  - **7 lines** (`1` line for `BooksScreen build` + `6` lines for `row <title>` across all 6 books). Calling `setState` in `Shell` marks the entire subtree below `Shell` dirty, rebuilding the whole screen and every row.

## Level 3: Provider Verbs — Loud vs. Silent Mistakes
- **Loud error (`context.watch<Cart>().add(b)` inside `onPressed` callback):**
  - Throws an assertion error at runtime:
    `Tried to listen to a value exposed with provider, from outside of the widget tree. This is likely caused by an event handler (like a button's onPressed) that called Provider.of without passing listen: false. To fix, write: Provider.of<Cart>(context, listen: false)` (or use `context.read<Cart>()`).
- **Silent error (`context.read<Cart>().count` inside `CartBadge.build`):**
  - No compile error and no runtime exception. The widget reads the initial value (`0`) once during its first build and never subscribes to `Cart` updates, so the badge stays frozen at `0` forever when books are added or removed.

## Level 4: Rebuild Counts (`watch` vs. `select` in `CartBadge`)
- **Pressing `+` 3 times on a Cart item with `context.watch<Cart>().count`:**
  - `CartBadge` rebuilds **3 times** (`badge build` printed 3 times), even though the distinct item `count` did not change.
- **Pressing `+` 3 times on a Cart item with `context.select<Cart, int>((c) => c.count)`:**
  - `CartBadge` rebuilds **0 times** (nothing printed), because `c.count` stayed constant. Removing a book prints `badge build` **1 time** because `count` actually changed.

## Level 5: Where Does It Live?
- **The cart:** **Provided** (`ChangeNotifierProvider` above `MaterialApp`) — shared across multiple routes (`BooksScreen`, `CartBadge`, `CartScreen`) that are distant in the widget tree.
- **The search text in a Books AppBar search field that filters the list:** **Ephemeral** (local `StatefulWidget` state inside `BooksScreen`) — only `BooksScreen` cares about the current filter text; no other route or widget outside `BooksScreen` needs it.
- **Whether the Cart screen's total is expanded or collapsed:** **Ephemeral** (local `StatefulWidget` state inside `CartScreen` or the total widget) — purely a local UI toggle confined to a single widget on the Cart screen.
- **The theme mode if there were a dark-mode switch:** **Provided** (or lifted to `Shell` above `MaterialApp`) — affects `MaterialApp.themeMode` at the root of the app while being toggled from a deeply nested settings/app bar widget.