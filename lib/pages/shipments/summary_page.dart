import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryPage extends StatelessWidget {
  final String category;
  final int weight;
  final int length;
  final int width;
  final int height;
  final String city;
  final String location;
  final String destination;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SummaryPage({
    required this.category,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
    required this.city,
    required this.location,
    required this.destination,
  });

  Future<void> _submitForm(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      final userId = user?.uid;
      await FirebaseFirestore.instance.collection('shipments').add({
        'category': this.category,
        'weight': this.weight,
        'length': this.length,
        'width': this.width,
        'height': this.height,
        'city': this.city,
        'location': this.location,
        'destination': this.destination,
        'userId': userId,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _buildDialogContent(context),
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add shipment'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
      print('Failed to add shipment: $error');
    }
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 100,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Your application has been submitted. Please wait until the admin approves your request.',
                style: TextStyle(
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 45,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shipment Summary',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: EdgeInsets.all(20.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade600,
                        spreadRadius: 1,
                        blurRadius: 15)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment Summary',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Category
                    _buildSummaryItem('Category', category),
                    // Weight
                    _buildSummaryItem('Weight', '$weight kg'),
                    // Dimensions
                    _buildSummaryItem(
                        'Dimensions(L*W*H)', '$length x $width x $height'),
                    // City
                    _buildSummaryItem('City', city),
                    // Location
                    _buildSummaryItem('Location', location),
                    // Destination
                    _buildSummaryItem('Destination', destination)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Submit Button
            ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 60),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))))
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white)),
        SizedBox(
          height: 10,
        ),
        Text(
          value,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Divider(
          height: 30,
          color: Colors.white,
        ),
      ],
    );
  }
}
