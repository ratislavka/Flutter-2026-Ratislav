import 'package:flutter/material.dart';
import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
    ),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      setState(() {
        _done = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done
        ? Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SummaryCard(
                  name: _name.text,
                  email: _email.text,
                  group: _group ?? '',
                  birthDate: _birthController.text,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _name.clear();
                      _email.clear();
                      _password.clear();
                      _confirm.clear();
                      _birthController.clear();
                      _group = null;
                      _birth = null;
                      _agreed = false;
                      _done = false;
                    });
                  },
                  child: const Text('Start over'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (v) => (v ?? '').trim().length < 2
                        ? 'Name is too short'
                        : null,
                  ),
                  TextFormField(
                    controller: _email,
                    focusNode: _emailFocus,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'name@kbtu.kz',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (v) {
                      final s = v ?? '';
                      final at = s.indexOf('@');
                      if (at == -1 || !s.substring(at).contains('.')) {
                        return 'Email looks wrong';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      helperText: 'At least 8 characters',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (v) => (v ?? '').length < 8
                        ? 'Password is too short'
                        : null,
                  ),
                  Text('${_password.text.length} of 8'),
                  TextFormField(
                    controller: _confirm,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    validator: (v) => v != _password.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _group,
                    decoration: const InputDecoration(labelText: 'Group'),
                    items: [
                      for (final g in groups)
                        DropdownMenuItem(value: g, child: Text(g)),
                    ],
                    onChanged: (g) => setState(() => _group = g),
                    validator: (g) => g == null ? 'Choose a group' : null,
                  ),
                  TextFormField(
                    controller: _birthController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date of birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked == null) return;
                      if (!mounted) return;
                      setState(() {
                        _birth = picked;
                        final d = picked.day.toString().padLeft(2, '0');
                        final m = picked.month.toString().padLeft(2, '0');
                        _birthController.text = '$d.$m.${picked.year}';
                      });
                    },
                    validator: (_) =>
                        _birth != null ? null : 'Choose a birth date',
                  ),
                  CheckboxListTile(
                    title: const Text('I agree to the rules'),
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _agreed ? _submit : null,
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ),
          ),
  );
}