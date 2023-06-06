import 'package:flutter/material.dart';
import 'package:speedyship/components/my_expansiontile.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [
          MyExpansionTile(title: 'How do I track my delivery?', details: const [
            'You can track your delivery through the "Orders" section in the app. Each order will have a tracking number and a link to follow the status of your delivery.'
          ]),
          MyExpansionTile(
              title: 'What are the delivery rates?',
              details: const [
                'Delivery rates depend on the size, weight, and destination of the package. You can check the rates during the shipment creation process.'
              ]),
          MyExpansionTile(
              title: 'How do I change my account information?',
              details: const [
                'To change your account information, go to the "Account" section in the app, and click on the "Edit Profile" button.'
              ]),
          MyExpansionTile(title: 'Need more help?', details: const [
            'If you still have questions or need assistance, feel free to contact our support team:',
            'Email: support@speedyship.com',
            'Phone: +1 (555) 123-4567',
          ])
        ]),
      ),
    );
  }
}
