import 'package:flutter/material.dart';
import 'package:speedyship/components/my_expansiontile.dart';

class CourierHelpPage extends StatelessWidget {
  const CourierHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [
          MyExpansionTile(title: 'How do I update my profile?', details: const [
            'To update your profile, go to the "Profile" tab, click on "Edit Profile", make the necessary changes, and save the changes.'
          ]),
          MyExpansionTile(
              title: 'What should I do if the app is not working properly?',
              details: const [
                'If the app is not working properly, try closing and reopening the app. If problems persist, please refer to the troubleshooting section in this manual.'
              ]),
          MyExpansionTile(
              title: 'How do I sign out of the app?',
              details: const [
                'To sign out of the app, navigate to the drawer , scroll to the bottom, and click on the "Log Out" button.'
              ]),
        ]),
      ),
    );
  }
}
