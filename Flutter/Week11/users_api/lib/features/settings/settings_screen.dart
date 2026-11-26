import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final cities = {
      for (final user in context.watch<UsersModel>().items)
        if (user.address.city.isNotEmpty) user.address.city,
      ?settings.city,
    }.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: settings.setDark,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'City filter'),
              initialValue: settings.city ?? '',
              items: [
                const DropdownMenuItem(value: '', child: Text('All cities')),
                for (final city in cities)
                  DropdownMenuItem(value: city, child: Text(city)),
              ],
              onChanged: (city) => settings.setCity(city == '' ? null : city),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              try {
                await context.read<AuthModel>().logout();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              } on Exception {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not sign out. Try again.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
