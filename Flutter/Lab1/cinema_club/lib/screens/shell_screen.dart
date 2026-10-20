import 'package:flutter/material.dart';
import '../data/seed_data.dart';
import '../models/profile.dart';
import '../models/screening.dart';
import '../routes.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  List<Screening> _screenings = buildSeedScreenings();
  Profile _profile = const Profile.empty();
  int _currentIndex = 0;

  void _updateScreening(Screening updated) {
    setState(() {
      _screenings = _screenings
          .map((Screening s) => s.id == updated.id ? updated : s)
          .toList();
    });
  }

  void _deleteScreening(String id) {
    setState(() {
      _screenings = _screenings.where((Screening s) => s.id != id).toList();
    });
  }

  void _toggleFavourite(Screening target) {
    _updateScreening(target.copyWith(favourite: !target.favourite));
  }

  Future<void> _openNewForm() async {
    final Screening? created = await Navigator.pushNamed<Screening>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) return;
    setState(() {
      _screenings = <Screening>[..._screenings, created];
    });
  }

  void _openDetail(Screening screening) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        screening: screening,
        profileName: _profile.name,
        onUpdated: _updateScreening,
        onDeleted: _deleteScreening,
        onSwitchToProfile: () {
          setState(() {
            _currentIndex = 2;
          });
        },
      ),
    );
  }

  Future<void> _showAboutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('About Cinema Club'),
        content: const Text(
          'Indie Cinema & Watch Party Club organizer.\n'
          'Built for Mobile Development Lab 1.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmResetData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Reset Data?'),
        content: const Text(
          'Restore all 12 seed screenings and clear your profile?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _screenings = buildSeedScreenings();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      ListTab(
        screenings: _screenings,
        onOpenDetail: _openDetail,
        onToggleFavourite: _toggleFavourite,
      ),
      FavouritesTab(
        screenings: _screenings,
        onOpenDetail: _openDetail,
        onToggleFavourite: _toggleFavourite,
      ),
      ProfileTab(
        profile: _profile,
        screenings: _screenings,
        themeMode: widget.themeMode,
        onProfileChanged: (Profile updated) {
          setState(() {
            _profile = updated;
          });
        },
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema Club'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.movie_outlined),
                title: Text('Cinema Club'),
                subtitle: Text('Screenings & Watch Parties'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmResetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _openNewForm,
              tooltip: 'New Screening',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Screenings',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}