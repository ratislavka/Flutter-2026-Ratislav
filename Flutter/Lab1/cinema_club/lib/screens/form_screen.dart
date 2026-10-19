import 'package:flutter/material.dart';
import '../models/film_genre.dart';
import '../models/screening.dart';
import '../routes.dart';
import '../utils/format.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final Screening _initial;
  late final bool _isEditing;

  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _noteController;

  late final FocusNode _titleFocus;
  late final FocusNode _placeFocus;
  late final FocusNode _limitFocus;
  late final FocusNode _noteFocus;

  FilmGenre? _selectedGenre;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isStream = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.args.screening != null;
    _initial = widget.args.screening ?? Screening.empty();

    _selectedGenre = widget.args.screening?.category ?? FilmGenre.sciFi;
    _isStream = _initial.isStream;
    _selectedDate = DateTime(
      _initial.when.year,
      _initial.when.month,
      _initial.when.day,
    );
    _selectedTime = TimeOfDay(
      hour: _initial.when.hour,
      minute: _initial.when.minute,
    );

    _titleController = TextEditingController(text: _initial.title);
    _placeController = TextEditingController(text: _initial.place);
    _limitController = TextEditingController(text: _initial.limit.toString());
    _dateController = TextEditingController(
      text: formatDateOnly(_initial.when),
    );
    _timeController = TextEditingController(
      text: formatTimeOnly(_initial.when.hour, _initial.when.minute),
    );
    _noteController = TextEditingController(text: _initial.note ?? '');

    _titleFocus = FocusNode();
    _placeFocus = FocusNode();
    _limitFocus = FocusNode();
    _noteFocus = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  DateTime _combinedDateTime() {
    final DateTime d = _selectedDate ?? _initial.when;
    final TimeOfDay t =
        _selectedTime ??
        TimeOfDay(hour: _initial.when.hour, minute: _initial.when.minute);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  bool get _isDirty {
    final String initNote = _initial.note ?? '';
    final DateTime currentWhen = _combinedDateTime();
    final DateTime initWhen = DateTime(
      _initial.when.year,
      _initial.when.month,
      _initial.when.day,
      _initial.when.hour,
      _initial.when.minute,
    );
    return _titleController.text != _initial.title ||
        _selectedGenre != _initial.category ||
        _isStream != _initial.isStream ||
        _placeController.text != _initial.place ||
        _limitController.text != _initial.limit.toString() ||
        _noteController.text != initNote ||
        currentWhen != initWhen;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initial = _selectedDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = formatDateOnly(picked);
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay initial =
        _selectedTime ?? const TimeOfDay(hour: 19, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedTime = picked;
      _timeController.text = formatTimeOnly(picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final String trimmedNote = _noteController.text.trim();
    final Screening result = _initial.copyWith(
      title: _titleController.text.trim(),
      category: _selectedGenre,
      when: _combinedDateTime(),
      place: _placeController.text.trim(),
      limit: int.parse(_limitController.text.trim()),
      isStream: _isStream,
      note: trimmedNote.isEmpty ? null : trimmedNote,
      clearNote: trimmedNote.isEmpty,
    );

    Navigator.pop(context, result);
  }

  Future<void> _confirmDiscard() async {
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Leave anyway?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving && !_isDirty,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop || _isSaving) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Screening' : 'New Screening'),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Movie / Screening Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.length < 3 || text.length > 60) {
                      return 'Title must be between 3 and 60 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<FilmGenre>(
                  initialValue: _selectedGenre,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    border: OutlineInputBorder(),
                  ),
                  items: <DropdownMenuItem<FilmGenre>>[
                    for (final FilmGenre g in FilmGenre.values)
                      DropdownMenuItem<FilmGenre>(
                        value: g,
                        child: Row(
                          children: <Widget>[
                            Icon(g.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(g.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (FilmGenre? value) {
                    setState(() {
                      _selectedGenre = value;
                    });
                  },
                  validator: (FilmGenre? value) =>
                      value == null ? 'Please select a genre' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online Watch Party Stream'),
                  subtitle: Text(
                    _isStream
                        ? 'Requires a valid stream link with ://'
                        : 'In-person cinema hall screening',
                  ),
                  value: _isStream,
                  onChanged: (bool value) {
                    setState(() {
                      _isStream = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  keyboardType: _isStream
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: _isStream ? 'Stream URL' : 'Cinema Hall / Venue',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final String text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return _isStream
                          ? 'Stream URL is required'
                          : 'Cinema hall is required';
                    }
                    if (_isStream && !text.contains('://')) {
                      return 'Stream link must contain ://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _limitController,
                  focusNode: _limitFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  onFieldSubmitted: (_) => _noteFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Seat Limit (1 - 500)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    final int? parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 1 || parsed > 500) {
                      return 'Enter a whole number from 1 to 500';
                    }
                    if (_isEditing && parsed < _initial.count) {
                      return 'Cannot be below current bookings (${_initial.count})';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!_isEditing &&
                              !_combinedDateTime().isAfter(DateTime.now())) {
                            return 'Must be in the future';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!_isEditing &&
                              !_combinedDateTime().isAfter(DateTime.now())) {
                            return 'Future time required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  focusNode: _noteFocus,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Curator Note (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (_) => null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Screening'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}