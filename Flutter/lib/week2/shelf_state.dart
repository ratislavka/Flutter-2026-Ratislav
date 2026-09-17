import 'models.dart';

sealed class ShelfState {}

class Empty extends ShelfState {}

class Ready extends ShelfState {
  final List<Book> books;

  Ready({required this.books});
}

class Broken extends ShelfState {
  final String message;

  Broken({required this.message});
}

String describe(ShelfState state) {
  return switch (state) {
    Empty() => "The shelf is empty.",
    Ready(books: final books) =>
      "The shelf is ready with ${books.length} books.",
    Broken(message: final message) => "The shelf is broken because: $message",
  };
}

({int count, double avgPages}) statsOf(List<Book> books) {
  final booksCount = books.length;
  final avgPages = books.fold(0, (sum, book) => sum + book.pages) / booksCount;
  return (count: booksCount, avgPages: avgPages);
}
