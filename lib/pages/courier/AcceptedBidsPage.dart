import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AcceptedBidsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User not logged in.',
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        ),
      );
    }

    final String currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(9, 147, 120, 1.0),
        title: Text(
          'Accepted Bids',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('acceptedBids')
            .where('courierId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No accepted bids available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String bidId = data['bidId'];
              final String userId = data['userId'];
              final int price = data['price'];
              final String date = data['date'];
              final String shipmentId = data['shipmentId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> userSnapshot,
                ) {
                  String title = 'Shipment ID: $shipmentId';
                  List<Widget> subtitle = [
                    Text('User ID: $userId', style: TextStyle(fontSize: 16)),
                    Text('Price: $price', style: TextStyle(fontSize: 16)),
                    Text('Date: $date', style: TextStyle(fontSize: 16)),
                  ];

                  if (userSnapshot.hasData && userSnapshot.data != null) {
                    final Map<String, dynamic> userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    final String firstName = userData['firstName'];
                    final String lastName = userData['lastName'];
                    subtitle = [
                      Text(
                        'User: $firstName $lastName',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text('Price:$price', style: TextStyle(fontSize: 16)),
                      Text('Date: $date', style: TextStyle(fontSize: 16)),
                    ];
                  }

                  return Card(
                    elevation: 2.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...subtitle,
                          SizedBox(
                              height:
                                  8.0), // Add some spacing between the subtitle and buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Begin Delivery button logic
                                  FirebaseFirestore.instance
                                      .collection('shipments')
                                      .doc(document['shipmentId'])
                                      .update({'status': 'pending'});
                                },
                                child: Text('Begin Delivery'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  // Cancel Delivery button logic
                                  FirebaseFirestore.instance
                                      .collection('shipments')
                                      .doc(document['shipmentId'])
                                      .update({'status': 'cancelled'});
                                },
                                child: Text('Cancel Delivery'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
