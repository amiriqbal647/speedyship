import 'package:flutter/material.dart';
import 'package:speedyship/components/my_button2.dart';
import 'package:speedyship/pages/courier/courier_main.dart';
import 'package:speedyship/pages/courier/courier_register.dart';

class BecomeCourierPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Become a Courier'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyExpansionTile(
                title: 'Why work with us?',
                details: [
                  'Flexible hours: Choose when and where you want to work. Whether you\'re looking for a full-time gig or just some extra cash on the side, we\'ve got you covered.',
                  'Competitive pay: We offer competitive rates based on distance and delivery type.',
                  'Easy to use app: Our user-friendly app makes it easy to manage your deliveries and track your earnings.',
                  'Supportive team: Our team is always here to help, whether you have questions about the app or need assistance with a delivery.',
                ],
              ),
              MyExpansionTile(
                title: 'Requirements',
                details: [
                  'A reliable vehicle (car, truck, or van)',
                  'A valid driver\'s license and insurance',
                  'A smartphone with internet access',
                  'Basic navigation skills',
                  'A positive attitude and excellent customer service skills',
                ],
              ),
              MyExpansionTile(
                title: 'How to apply',
                details: [
                  'To apply to become a courier, simply fill out our online application form. We\'ll review your application and get back to you within 48 hours.',
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: MyButton2(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentUploader(),
                      ),
                    );
                  },
                  buttonText: 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyExpansionTile extends StatelessWidget {
  final String title;
  final List<String> details;

  MyExpansionTile({required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.all(0),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      children: details
          .map((detail) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  detail,
                  style: TextStyle(fontSize: 16.0),
                ),
              ))
          .toList(),
    );
  }
}
