import 'package:flutter/material.dart';
import 'models/screening.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

abstract final class Routes {
  static const String shell = '/';
  static const String detail = '/detail';
  static const String form = '/form';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case detail:
        final Object? args = settings.arguments;
        if (args is DetailArgs) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => DetailScreen(args: args),
          );
        }
        return _notFoundRoute(settings);
      case form:
        final Object? args = settings.arguments;
        if (args is FormArgs) {
          return MaterialPageRoute<Screening>(
            settings: settings,
            builder: (_) => FormScreen(args: args),
          );
        }
        return _notFoundRoute(settings);
      default:
        return _notFoundRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _notFoundRoute(settings);
  }

  static Route<dynamic> _notFoundRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('Not found')),
      ),
    );
  }
}

class DetailArgs {
  const DetailArgs({
    required this.screening,
    required this.profileName,
    required this.onUpdated,
    required this.onDeleted,
    required this.onSwitchToProfile,
  });

  final Screening screening;
  final String profileName;
  final ValueChanged<Screening> onUpdated;
  final ValueChanged<String> onDeleted;
  final VoidCallback onSwitchToProfile;
}

class FormArgs {
  const FormArgs({this.screening});
  final Screening? screening;
}