import 'dart:async';

// Keep the Material import used by the practice SDK.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/storage/secure_store.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/settings_model.dart';

import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'users_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    final model = context.read<UsersModel>();
    scheduleMicrotask(model.load);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersModel>(
      builder: (context, model, child) {
        final city = context.watch<SettingsModel>().city;
        final visible = model.items
            .where((u) => city == null || u.address.city == city)
            .toList();
        final Widget body;
        if (model.loading && model.items.isEmpty) {
          body = const LoadingView();
        } else {
          body = switch (model.error) {
            null => Column(
              children: [
                if (model.fromCache)
                  MaterialBanner(
                    content: const Text('Saved data · no connection'),
                    actions: [
                      TextButton(
                        onPressed: model.loading ? null : model.load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                Expanded(
                  child: visible.isEmpty && city != null
                      ? Center(child: Text('No users in $city'))
                      : UserList(items: visible, onRefresh: model.load),
                ),
              ],
            ),
            NoConnectionException() => Offline(onRetry: model.load),
            NotFoundException() => const GenericError(
              message: 'The requested users were not found.',
            ),
            UnauthorizedException() => const GenericError(
              message: 'Access denied by the server.',
            ),
            ServerException(:final status) => ServerError(
              status: status,
              onRetry: model.load,
            ),
            BadResponseException() => const GenericError(
              message: 'The server sent unexpected data.',
            ),
          };
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Users'),
            actions: [
              IconButton(
                tooltip: 'Profile',
                icon: const Icon(Icons.person_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ProfileScreen(),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: body,
          floatingActionButton: model.loading
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const NewUserScreen(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('New user'),
                ),
        );
      },
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class UserList extends StatelessWidget {
  const UserList({required this.items, required this.onRefresh, super.key});

  final List<User> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = items[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email}\n${user.address.city}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              unawaited(
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => UserDetailScreen(user: user),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Offline extends StatelessWidget {
  const Offline({required this.onRetry, super.key});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.wifi_off,
      title: 'No connection',
      message: 'Could not reach JSONPlaceholder. Check your network and retry.',
      onRetry: onRetry,
    );
  }
}

class ServerError extends StatelessWidget {
  const ServerError({required this.status, required this.onRetry, super.key});

  final int status;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.cloud_off,
      title: 'Server error ($status)',
      message: 'The service is temporarily unavailable.',
      onRetry: onRetry,
    );
  }
}

class GenericError extends StatelessWidget {
  const GenericError({this.message = 'Something went wrong.', super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _StateView(
      icon: Icons.error_outline,
      title: 'Unable to load users',
      message: message,
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({required this.user, super.key});

  final User user;

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } on PlatformException {
      // Some platforms report a missing handler as an exception.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No app can open this')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          const _SectionTitle('Profile'),
          _DetailRow('ID', '${user.id}'),
          _DetailRow('Name', user.name),
          _DetailRow('Username', user.username),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user.email),
            trailing: const Icon(Icons.email_outlined),
            onTap: () =>
                _launch(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phone),
            trailing: const Icon(Icons.phone_outlined),
            onTap: user.phoneDigits.isEmpty
                ? null
                : () => _launch(
                    context,
                    Uri(scheme: 'tel', path: user.phoneDigits),
                  ),
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(user.website ?? 'Not provided'),
            trailing: const Icon(Icons.public),
            onTap: (user.website ?? '').isEmpty
                ? null
                : () => _launch(context, Uri.parse('https://${user.website}')),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Copy token to clipboard'),
              leading: const Icon(Icons.copy),
              onTap: () async {
                final token = await context.read<SecureStore>().readToken();
                if (token != null) {
                  await Clipboard.setData(ClipboardData(text: token));
                }
              },
            ),
          const _SectionTitle('Address'),
          _DetailRow('Street', user.address.street),
          _DetailRow('Suite', user.address.suite),
          _DetailRow('City', user.address.city),
          _DetailRow('Zip code', user.address.zipcode),
          _DetailRow('Latitude', '${user.address.geo.lat}'),
          _DetailRow('Longitude', '${user.address.geo.lng}'),
          const _SectionTitle('Company'),
          _DetailRow('Name', user.company.name),
          _DetailRow('Catch phrase', user.company.catchPhrase),
          _DetailRow('Business', user.companyBs),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value.isEmpty ? '—' : value),
    );
  }
}
