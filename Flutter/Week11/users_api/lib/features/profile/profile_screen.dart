import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? avatar;
  bool busy = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved =
          await context.read<SharedPreferencesAsync>().getString(
            'avatarPath',
          ) ??
          '';
      if (saved.isEmpty) return;
      final directory = await getApplicationDocumentsDirectory();
      final file = File.fromUri(
        directory.uri.resolve(File(saved).uri.pathSegments.last),
      );
      if (await file.exists() && mounted) setState(() => avatar = file);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _cameraAllowed() async {
    final status = await Permission.camera.request();
    if (!mounted) return false;
    switch (status) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        final open = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow camera access?'),
            content: const Text(
              'Enable the camera in Settings to take a profile photo. You can also choose a photo from your gallery.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (open == true && !await openAppSettings() && mounted) {
          message('Could not open settings.');
        }
        return false;
      case PermissionStatus.denied:
        message('Camera access was denied. You can still choose a photo.');
        return false;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        message('Camera access is restricted. You can still choose a photo.');
        return false;
    }
  }

  Future<void> _pick(ImageSource source) async {
    if (busy) return;
    final prefs = context.read<SharedPreferencesAsync>();
    setState(() => busy = true);
    try {
      if (source == ImageSource.camera && !await _cameraAllowed()) return;
      if (!mounted) return;
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/avatar.jpg');
      final temporary = await File(picked.path).copy('${file.path}.tmp');
      await temporary.rename(file.path);
      await prefs.setString('avatarPath', file.path);
      await FileImage(file).evict();
      if (mounted) setState(() => avatar = file);
    } on FileSystemException {
      if (mounted) message('Could not save the photo.');
    } on PlatformException {
      if (mounted) message('The photo source is unavailable.');
    } on MissingPluginException {
      if (mounted) message('This device does not support this photo source.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage: switch (avatar) {
              final file? => FileImage(file),
              null => null,
            },
            child: avatar == null ? const Text('P') : null,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: busy ? null : () => _pick(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose photo'),
        ),
        FilledButton.icon(
          onPressed: busy ? null : () => _pick(ImageSource.camera),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take photo'),
        ),
      ],
    ),
  );
}
