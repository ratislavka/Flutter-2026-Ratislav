class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  // const Author({
  //   this.name = name,
  //   if country != null
  //     this.country = country,
  // })

  @override
  String toString() {
    if (country != null) {
      return "Author's name is $name and he is from $country";
    } else {
      return "Author's name is $name";
    }
  }
}

enum Genre {
  craft("Craft"),
  theory("Theory"),
  unknown("Unknown");

  final String label;
  const Genre(this.label);
}

abstract class LibraryItem {
  final String title;
  final int year;

  String describe();

  const LibraryItem({required this.title, required this.year});

  bool get isOld {
    return year < 1900;
  }
}

mixin Borrowable on LibraryItem {
  String borrowLabel() {
    return "Borrow: $title";
  }
}

class Book extends LibraryItem with Borrowable {
  // final String title;
  // final int year;
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    // required this.title,
    // required this.year,
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });

  const Book.unknown({
    // this.title = 'Unknown',
    // this.year = 0,
    super.title = 'Unknown',
    super.year = 0,
    this.pages = 0,
    this.author = const Author(name: 'Unknown', country: 'Unknown'),
    this.genre = Genre.unknown,
    this.description = 'Unknown',
  });

  // factory Book.fromJson(Map<String, dynamic> json) {
  //   return Book(
  //     title: json['title'] ?? 'Unknown',
  //     year: json['year'] ?? 0,
  //     pages: json['pages'] ?? 0,
  //     // author: json['author'] ?? 'Unknown',
  //     author: Author(
  //       name: json['author'],
  //       country: json['country'] ?? 'Unknown',
  //     ),
  //     genre: json['genre'] ?? Genre.unknown,
  //     description: json['description'],
  //   );
  // }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? 'Unknown',
      year: json['year'] ?? 0,
      pages: json['pages'] ?? 0,
      author: Author(
        name: json['author'] ?? 'Unknown',
        country: json['country'] ?? 'Unknown',
      ),
      genre: switch (json['genre']) {
        'craft' => Genre.craft,
        'theory' => Genre.theory,
        _ => Genre.unknown,
      },
      description: json['description'],
    );
  }

  bool get isLong {
    return pages > 400;
  }

  String? get country => null;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      author: author ?? const Author(name: 'Unknown', country: 'Unknown'),
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  // @override
  // String toString() {
  //   return "Book's title is $title, year of publications is $year, its number of pages is $pages, the author is $author, its genre is $genre and the desctiotion is $desctiption";
  // }

  @override
  String toString() {
    if (description != "Unknown") {
      return "Book's title is $title, year of publications is $year, its number of pages is $pages, the author is $author, its genre is $genre and the desctiotion is $description";
    } else {
      return "Book's title is $title, year of publications is $year, its number of pages is $pages, the author is $author, and its genre is $genre";
    }
  }

  @override
  String describe() {
    return "Book: $title by $author";
  }
}

class Magazine extends LibraryItem {
  final String issue;

  const Magazine({
    // required String title,
    // required int year,
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() {
    return "Magazine's title is $title, publication year is $year, and its issue is $issue";
  }
}

class Ghost implements LibraryItem {
  @override
  final String title = "Ghost";
  @override
  final int year = 0;

  @override
  bool get isOld => false;

  @override
  String describe() {
    return "Ghost's title is $title, publication year is $year";
  }
}
