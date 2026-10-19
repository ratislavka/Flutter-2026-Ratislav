import 'dart:async';
import 'package:flutter/material.dart';
import '../models/countdown.dart';
import '../models/screening.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Screening _screening;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _screening = widget.args.screening;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    final String profileName = widget.args.profileName.trim();
    if (profileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your profile name first to book seats.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.pop(context);
              widget.args.onSwitchToProfile();
            },
          ),
        ),
      );
      return;
    }

    final bool isJoined = _screening.contains(profileName);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(isJoined ? 'Cancel Seat?' : 'Book Seat?'),
        content: Text(
          isJoined
              ? 'Remove "$profileName" from ${_screening.title}?'
              : 'Reserve a seat for "$profileName" at ${_screening.title}?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final List<String> updatedAudience = isJoined
        ? _screening.audience.where((String n) => n != profileName).toList()
        : <String>[..._screening.audience, profileName];

    final Screening updated = _screening.copyWith(audience: updatedAudience);
    setState(() {
      _screening = updated;
    });
    widget.args.onUpdated(updated);
  }

  Future<void> _handleEdit() async {
    final Screening? updated = await Navigator.pushNamed<Screening>(
      context,
      Routes.form,
      arguments: FormArgs(screening: _screening),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _screening = updated;
    });
    widget.args.onUpdated(updated);
  }

  Future<void> _handleDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Screening?'),
        content: Text('Delete "${_screening.title}" permanently?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    widget.args.onDeleted(_screening.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color genreColor = _screening.category.color(scheme);
    final Countdown countdown = Countdown.from(_screening.when, DateTime.now());
    final (int taken, int free) = _screening.places;
    final String user = widget.args.profileName.trim();
    final bool isJoined = _screening.contains(user);
    final bool canAct = !_screening.isPast && (isJoined || !_screening.isFull);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_screening.title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'edit') {
                  _handleEdit();
                } else if (value == 'delete') {
                  _handleDelete();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    'assets/banner.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: scheme.surfaceContainerHighest,
                    ),
                  ),
                  ColoredBox(color: genreColor.withValues(alpha: 0.25)),
                  Center(
                    child: Icon(
                      _screening.category.icon,
                      size: 56,
                      color: scheme.onSurface,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(
                      avatar: Icon(_screening.category.icon, size: 16),
                      label: Text(_screening.category.label),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Chip(
                      label: Text(formatCountdown(countdown)),
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: <Widget>[
                const Tab(text: 'About'),
                Tab(text: 'Audience (${_screening.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Text(_screening.title, style: textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: const Text('Showtime'),
                        subtitle: Text(formatDateTime(_screening.when)),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _screening.isStream ? Icons.link : Icons.theaters,
                        ),
                        title: Text(
                          _screening.isStream ? 'Stream Link' : 'Cinema Hall',
                        ),
                        subtitle: Text(_screening.place),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_seat_outlined),
                        title: const Text('Seats'),
                        subtitle: Text(
                          '$taken / ${_screening.limit} booked ($free free)',
                        ),
                      ),
                      if (_screening.note case final String text
                          when text.isNotEmpty) ...<Widget>[
                        const Divider(height: 24),
                        Text('Curator Note', style: textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(text, style: textTheme.bodyMedium),
                      ],
                    ],
                  ),
                  _screening.audience.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody on the audience list yet.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _screening.audience.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String member = _screening.audience[index];
                            final bool isYou =
                                user.isNotEmpty && member == user;
                            return Card(
                              color: isYou
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerLow,
                              child: ListTile(
                                leading: Icon(
                                  isYou ? Icons.star : Icons.person_outline,
                                ),
                                title: Text(isYou ? '$member (You)' : member),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: canAct ? _handlePrimaryAction : null,
              child: Text(isJoined ? 'Cancel Seat' : 'Book Seat'),
            ),
          ),
        ),
      ),
    );
  }
}