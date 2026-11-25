import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/users.json');
  }

  Future<void> save(List<User> users) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode([for (final user in users) user.toJson()]),
      flush: true,
    );
    await temporary.rename(file.path);
  }

  Future<List<User>?> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final rows = jsonDecode(await file.readAsString()) as List;
      return [
        for (final row in rows) User.fromJson(row as Map<String, dynamic>),
      ];
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
