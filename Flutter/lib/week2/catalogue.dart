import 'models.dart';

class Library {
  final List<LibraryItem> items = [];
  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  Book? findByTitle(String title) {
    return items
        .whereType<Book>()
        .where((book) => book.title == title)
        .firstOrNull;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'Unknown';
  }

  void open() {
    openedAt = DateTime.now();
  }

  String buildReport() {
    return _cachedReport ??= "Report is empty";
  }

  Iterable<String> get allTitles {
    return items.map((item) => item.title);
  }

  Iterable<Book> get booksAfter2010 {
    return items.whereType<Book>().where((book) => book.year > 2010);
  }

  double get averagePageCount {
    final books = items.whereType<Book>();
    final totalPages = books.fold(0, (sum, book) => sum + book.pages);

    return totalPages / books.length;
  }

  Map<String, int> get authorBookCount {
    return items.whereType<Book>().fold(
      <String, int>{},
      (map, book) =>
          map
            ..update(book.author.name, (count) => count + 1, ifAbsent: () => 1),
    );
  }

  Set<String> get distinctAuthors {
    return items.whereType<Book>().map((book) => book.author.name).toSet();
  }

  Set<Genre> get distinctGenres {
    return items.whereType<Book>().map((book) => book.genre).toSet();
  }
}
