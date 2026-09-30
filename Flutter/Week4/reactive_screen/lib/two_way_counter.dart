import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TwoWayCounterState();
  }
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int _count = 0;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            OutlinedButton(
              onPressed: _count == 0
                  ? null
                  : () {
                      setState(() {
                        _count--;
                      });
                    },
              child: const Text("-"),
            ),
            Text("$_count"),
            FilledButton(
              onPressed: () {
                setState(() {
                  _count++;
                });
              },
              child: const Text("+"),
            ),
          ],
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() {
                    _saving = true;
                  });

                  await Future.delayed(const Duration(seconds: 2));

                  if (!context.mounted) return;

                  setState(() {
                    _saving = false;
                  });

                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Saved')));
                },
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}
