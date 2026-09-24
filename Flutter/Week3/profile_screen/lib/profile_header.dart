import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/avatar.jpg',
              height: 250,
              width: 250,
            ),
          ),
        ),
        Text(
          name,
          style: const TextStyle(fontFamily: 'Jim Nightshade', fontSize: 30),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Text(university, style: const TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
