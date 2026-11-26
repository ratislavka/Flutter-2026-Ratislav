import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  String email = '', password = '';
  bool busy = false;

  Future<void> submit() async {
    if (busy || form.currentState?.validate() != true) return;
    setState(() => busy = true);
    try {
      await context.read<AuthModel>().login(email.trim(), password);
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your login. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign in')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => email = v,
            validator: (v) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim())
                ? null
                : 'Enter a valid email',
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            onChanged: (v) => password = v,
            validator: (v) =>
                (v ?? '').length >= 8 ? null : 'Use at least 8 characters',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : submit,
            child: Text(busy ? 'Signing in…' : 'Sign in'),
          ),
        ],
      ),
    ),
  );
}
