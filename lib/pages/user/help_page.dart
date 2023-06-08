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
          MyExpansionTile(
              title: 'How do I place a shipment order on the platform?',
              details: const [
                'To place a shipment order, navigate to the "Create Shipment" section, fill out the necessary information such as pick-up location, drop-off location, package details, and click on the "Create Shipment" button.'
              ]),
          MyExpansionTile(title: 'How do I track my shipment?', details: const [
            'To track your shipment, navigate to the "Orders" in the drawer and veiw the processing or cancelled or delivered shipments. '
          ]),
          MyExpansionTile(
              title: 'How do I accept or reject a bid?',
              details: const [
                'To accept or reject a bid, navigate to the “Requests” section, select the bid you want to respond to, and choose either "Accept" or "Reject".'
              ]),
          MyExpansionTile(title: 'How do I update my profile?', details: const [
            'To update your profile, go to the "Profile" tab, click on "Edit Profile", make the necessary changes, and save the changes.',
          ])
        ]),
      ),
    );
  }
}
