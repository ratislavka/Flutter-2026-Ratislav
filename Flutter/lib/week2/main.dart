import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final libraryBooks = rawBooks.map((json) => Book.fromJson(json)).toList();

  print("Stats: ${statsOf(libraryBooks)}");
  print(describe(Empty()));
  print(describe(Ready(books: libraryBooks)));
  print(describe(Broken(message: "The shelf is broken")));
}
