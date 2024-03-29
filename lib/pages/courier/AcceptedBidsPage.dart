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
        title: const Text('Accepted Bids'),
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
                      Text('Price: $price', style: TextStyle(fontSize: 16)),
                      Text('Date: $date', style: TextStyle(fontSize: 16)),
                    ];
                  }

                  return Dismissible(
                    key: Key(bidId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Action'),
                            content: Text(
                                'Are you sure you want to begin delivery?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      // Remove the entry from the list
                      FirebaseFirestore.instance
                          .collection('acceptedBids')
                          .doc(document.id)
                          .delete();
                    },
                    child: Card(
                      elevation: 2,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
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
                                FilledButton(
                                  onPressed: () async {
                                    // Show a confirmation dialog
                                    bool confirmAction = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm Action'),
                                          content: Text(
                                              'Are you sure you want to begin delivery?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmAction == true) {
                                      // Begin Delivery button logic
                                      FirebaseFirestore.instance
                                          .collection('shipments')
                                          .doc(document['shipmentId'])
                                          .update({'status': 'pending'});

                                      // Remove the entry from the list
                                      FirebaseFirestore.instance
                                          .collection('acceptedBids')
                                          .doc(document.id)
                                          .delete();
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                      fixedSize: const Size.fromHeight(40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  child: const Text('Begin Delivery'),
                                ),
                                const SizedBox(width: 10.0),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Show a confirmation dialog
                                    bool confirmAction = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm Action'),
                                          content: Text(
                                              'Are you sure you want to cancel delivery?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmAction == true) {
                                      // Cancel Delivery button logic
                                      FirebaseFirestore.instance
                                          .collection('shipments')
                                          .doc(document['shipmentId'])
                                          .update({'status': 'cancelled'});

                                      // Remove the entry from the list
                                      FirebaseFirestore.instance
                                          .collection('acceptedBids')
                                          .doc(document.id)
                                          .delete();
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                      fixedSize: const Size.fromHeight(40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  child: const Text('Cancel Delivery'),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            )
                          ],
                        ),
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
