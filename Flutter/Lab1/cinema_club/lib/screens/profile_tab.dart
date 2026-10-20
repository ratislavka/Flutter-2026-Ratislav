import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/screening.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.screenings,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Screening> screenings;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;
  static final RegExp _groupRegExp = RegExp(r'^[A-Za-z]{2,4}-\d{2,4}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.name;
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onProfileChanged(
        widget.profile.copyWith(
          name: _nameController.text.trim(),
          group: _groupController.text.trim(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int joinedCount = widget.screenings.fold<int>(
      0,
      (int acc, Screening item) =>
          item.contains(widget.profile.name) ? acc + 1 : acc,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Member Profile', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'You are on $joinedCount lists',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Press Enter to save',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().length < 2) {
                  return 'Enter at least 2 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _saveProfile(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _groupController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Group (e.g. SIS-2301)',
                hintText: 'Format: XX-00 to XXXX-0000',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                final String trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return null;
                if (!_groupRegExp.hasMatch(trimmed)) {
                  return 'Use format like SIS-2301';
                }
                return null;
              },
              onFieldSubmitted: (_) => _saveProfile(),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 24),
            Text('Appearance', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: <Widget>[
                ChoiceChip(
                  label: const Text('System'),
                  selected: widget.themeMode == ThemeMode.system,
                  onSelected: (_) =>
                      widget.onThemeModeChanged(ThemeMode.system),
                ),
                ChoiceChip(
                  label: const Text('Light'),
                  selected: widget.themeMode == ThemeMode.light,
                  onSelected: (_) => widget.onThemeModeChanged(ThemeMode.light),
                ),
                ChoiceChip(
                  label: const Text('Dark'),
                  selected: widget.themeMode == ThemeMode.dark,
                  onSelected: (_) => widget.onThemeModeChanged(ThemeMode.dark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}