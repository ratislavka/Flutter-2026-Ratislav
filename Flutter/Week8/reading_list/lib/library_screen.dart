import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
    Filter.all => _books,
    Filter.unread => unread(_books),
    Filter.read => _books.where((b) => b.read).toList(),
  };

  Future<void> _openDetail(Book book) async {
    final action = await Navigator.of(context).push<BookAction>(
      MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
    );
    if (!mounted) return;
    switch (action) {
      case null:
        break;
      case BookAction.toggleRead:
        setState(() => book.read = !book.read);
      case BookAction.delete:
        setState(() => _books.remove(book));
    }
  }

  Future<void> _openAddBook() async {
    final book = await Navigator.of(context)
        .push<Book>(MaterialPageRoute(builder: (_) => const AddBookScreen()));
    if (!mounted) return;
    if (book == null) return;
    setState(() => _books.add(book));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleBooks = _visible;

    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visibleBooks.length})')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_books.length}',
                            style: textTheme.headlineSmall,
                          ),
                          Text('Books', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${totalPages(_books)}',
                            style: textTheme.headlineSmall,
                          ),
                          Text('Pages', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${unread(_books).length}',
                            style: textTheme.headlineSmall,
                          ),
                          Text('Unread', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == Filter.all,
                  onSelected: (_) => setState(() => _filter = Filter.all),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Unread'),
                  selected: _filter == Filter.unread,
                  onSelected: (_) => setState(() => _filter = Filter.unread),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Read'),
                  selected: _filter == Filter.read,
                  onSelected: (_) => setState(() => _filter = Filter.read),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: visibleBooks.length,
                itemBuilder: (context, index) {
                  final book = visibleBooks[index];
                  return BookTile(
                    book: book,
                    onToggle: () => setState(() => book.read = !book.read),
                    onTap: () => _openDetail(book),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
