import 'package:flutter/material.dart';
import 'package:profile_screen/data.dart';
import 'profile_header.dart';
import 'info_row.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight(900)),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              ProfileHeader(name: myName, university: myUniversity),
              for (final fact in facts)
                InfoRow(label: fact.label, value: fact.value),
            ],
          ),
        ),
      ),
    );
  }
}
