import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
// Keep the Material import used by the practice SDK.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'features/auth/login_screen.dart';
import 'features/settings/settings_model.dart';
import 'features/users/users_cache.dart';
import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'features/users/user.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

// Run `flutter run --dart-define=RUN_LAB_CHECKS=true`  Level 2 and 3.
const bool runLabChecks = bool.fromEnvironment('RUN_LAB_CHECKS');

const String user1Json = r'''
{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {"lat": "-37.3159", "lng": "81.1496"}
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
''';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = SharedPreferencesAsync();
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter') ?? '';
  const store = SecureStore();
  final token = await store.readToken();
  final repository = UserRepository(
    ApiClient(HttpClient(), store),
    UsersCache(),
  );

  if (kDebugMode && runLabChecks) {
    try {
      await runConsoleChecks(repository);
    } on ApiException catch (error) {
      debugPrint('Practice 11 console checks stopped: ${error.runtimeType}');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: prefs),
        Provider.value(value: store),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(
            prefs,
            dark: dark,
            city: city.isEmpty ? null : city,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthModel(store, token)),
        ChangeNotifierProvider(
          create: (_) {
            return UsersModel(repository);
          },
        ),
      ],
      child: const App(),
    ),
  );
}

Future<void> runConsoleChecks(UserRepository repository) async {
  final user = User.fromJson(jsonDecode(user1Json) as Map<String, dynamic>);
  debugPrint('User 1: $user');
  final roundTrip = User.fromJson(user.toJson());
  debugPrint('Round trip: ${roundTrip.toJson()}');

  final all = await repository.getAll();
  for (final user in all.items) {
    debugPrint(user.name);
  }

  try {
    await repository.getById(999);
  } on NotFoundException {
    debugPrint('not found');
  }

  final created = await repository.create(
    User.draft(
      name: 'Practice Student',
      username: 'practice11',
      email: 'student@example.com',
    ),
  );
  debugPrint('Created user id: ${created.id}');
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users',
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<SettingsModel>().dark
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: context.watch<AuthModel>().signedIn
          ? const UsersScreen()
          : const LoginScreen(),
    );
  }
}
