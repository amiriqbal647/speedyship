import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RejectedBidsPage extends StatelessWidget {
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
        title: const Text(
          'Declined Bids',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('declinedBids')
            .where('courierId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                'No declined bids available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String bidId = data['bidId'];
              final String userId = data['userId'];
              final int price = data['price'];
              final String date = data['date'];
              final String shipmentId = data['shipmentId'];

              return Dismissible(
                key: Key(bidId),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Perform your action when the card is dismissed
                  // For example, you can remove the bid from the database
                  FirebaseFirestore.instance
                      .collection('declinedBids')
                      .doc(bidId)
                      .delete();
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
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
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: subtitle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
