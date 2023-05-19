import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CourierBids.dart';

class IndividualUserShipment extends StatelessWidget {
  final String location;
  final String destination;
  final String category;
  final int height;
  final int weight;
  final int width;
  final int length;
  final String username;
  final String userId;
  final String shipmentId;

  const IndividualUserShipment({
    required this.location,
    required this.destination,
    required this.category,
    required this.height,
    required this.weight,
    required this.width,
    required this.length,
    required this.username,
    required this.userId,
    required this.shipmentId, required city,
  });

  Future<bool> checkIfBidPlaced(String userId, String shipmentId) async {
    // Check if the courier has already placed a bid for this shipment
    final querySnapshot = await FirebaseFirestore.instance
        .collection('bids')
        .where('userId', isEqualTo: userId)
        .where('shipmentId', isEqualTo: shipmentId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Individual Shipment',
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
                      'Shipment Details',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _buildSummaryItem('Location', location),
                    _buildSummaryItem('Destination', destination),
                    _buildSummaryItem('Category', category),
                    _buildSummaryItem('Height', '$height'),
                    _buildSummaryItem('Weight', '$weight kg'),
                    _buildSummaryItem('Width', '$width'),
                    _buildSummaryItem('Length', '$length'),
                    _buildSummaryItem('Username', username),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Button
            Center(
              child: ElevatedButton(
                child: Text("Make a bid"),
                onPressed: () async {
                  final bidPlaced = await checkIfBidPlaced(userId, shipmentId);
                  if (bidPlaced) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Bid Already Placed'),
                          content: Text(
                              'You have already placed a bid for this shipment.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourierBidsForm(
                          userId: userId,
                          shipmentId: shipmentId,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(350, 60),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
            )
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
