import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

enum CountdownMode { stream, manual }

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  CountdownMode _mode = CountdownMode.stream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),

      body: Column(
        children: [
          const SizedBox(height: 20),

          SegmentedButton<CountdownMode>(
            segments: const [
              ButtonSegment(
                value: CountdownMode.stream,
                label: Text('StreamBuilder'),
              ),
              ButtonSegment(value: CountdownMode.manual, label: Text('Manual')),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() {
                _mode = selection.first;
              });
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: _mode == CountdownMode.stream
                ? const CountdownStreamView()
                : const CountdownManualView(),
          ),
        ],
      ),
    );
  }
}


class CountdownStreamView extends StatefulWidget {
  const CountdownStreamView({super.key});

  @override
  State<CountdownStreamView> createState() => _CountdownStreamViewState();
}

class _CountdownStreamViewState extends State<CountdownStreamView> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<int>(
        stream: _stream,
        builder: (context, snapshot) {
          final value = snapshot.data ?? 10;

          return Text(
            '$value',
            style: Theme.of(context).textTheme.displayLarge,
          );
        },
      ),
    );
  }
}


class CountdownManualView extends StatefulWidget {
  const CountdownManualView({super.key});

  @override
  State<CountdownManualView> createState() => _CountdownManualViewState();
}

class _CountdownManualViewState extends State<CountdownManualView> {
  int _left = 10;

  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();

    _sub = countdown(10).listen((value) {
      setState(() {
        _left = value;
      });
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
