import 'package:flutter/material.dart';
import 'package:never_overflows/contact_card.dart';
import 'package:never_overflows/contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  //list view asks for infinity
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        return ContactCard(contact: contacts[index]);
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: contacts.length,
    );
  }
}
