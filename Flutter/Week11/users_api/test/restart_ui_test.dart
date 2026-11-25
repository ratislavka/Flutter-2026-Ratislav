import 'dart:convert';
import 'dart:io';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:users_api/features/profile/profile_screen.dart';
import 'package:users_api/features/settings/settings_model.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';
import 'package:users_api/features/users/users_model.dart';
import 'package:users_api/features/users/users_screen.dart';
import 'package:users_api/main.dart' show user1Json;

class _Preferences extends Fake implements SharedPreferencesAsync {
  @override
  Future<String?> getString(String key) async => null;
}

class _Repository extends Fake implements UserRepository {
  @override
  void close() {}

  bool offline = true;
  @override
  Future<({List<User> items, bool fromCache})> getAll() async => (
    items: [User.fromJson(jsonDecode(user1Json) as Map<String, dynamic>)],
    fromCache: offline,
  );
}

void main() {
  const capture = bool.fromEnvironment('CAPTURE_SCREENSHOTS');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!capture) return;
    final root = Platform.environment['FLUTTER_ROOT'];
    final data = await File(
      '$root/engine/src/flutter/txt/third_party/fonts/Roboto-Regular.ttf',
    ).readAsBytes();
    await (FontLoader(
      'Roboto',
    )..addFont(Future.value(ByteData.sublistView(data)))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  Future<void> render(WidgetTester tester, Widget screen) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 720);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cached list stays visible on offline retry and loses its banner on recovery',
    (tester) async {
      final repository = _Repository();
      await render(
        tester,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  SettingsModel(_Preferences(), dark: false, city: null),
            ),
            ChangeNotifierProvider(create: (_) => UsersModel(repository)),
          ],
          child: const UsersScreen(),
        ),
      );
      expect(find.text('Leanne Graham'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Saved data · no connection'), findsOneWidget);
      if (capture) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('../screenshot_offline_banner.png'),
        );
      }
      repository.offline = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Leanne Graham'), findsOneWidget);
    },
  );

  testWidgets('permanent camera denial opens the app settings dialog', (
    tester,
  ) async {
    var openedSettings = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (call) async {
        if (call.method == 'requestPermissions') {
          return {
            Permission.camera.value: PermissionStatus.permanentlyDenied.index,
          };
        }
        if (call.method == 'openAppSettings') openedSettings = true;
        return true;
      },
    );
    await render(
      tester,
      Provider<SharedPreferencesAsync>.value(
        value: _Preferences(),
        child: const ProfileScreen(),
      ),
    );
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    if (capture) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../screenshot_permission_dialog.png'),
      );
    }
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(openedSettings, isTrue);
  });
}
