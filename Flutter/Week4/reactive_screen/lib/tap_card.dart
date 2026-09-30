import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TapCardState();
  }
}

class _TapCardState extends State<TapCard> {
  int _taps = 0;

  Future<void> _showResetDialog() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset the count?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      setState(() {
        _taps = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _taps++;
          });
        },
        onLongPress: _showResetDialog,
        child: ListTile(
          title: const Text("Tap this card"),
          trailing: Text("$_taps"),
        ),
      ),
    );
  }
}
