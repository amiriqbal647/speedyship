import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bid_operations.dart';
import 'package:elegant_notification/elegant_notification.dart';

class BidsPage extends StatefulWidget {
  @override
  _BidsPageState createState() => _BidsPageState();
}

class _BidsPageState extends State<BidsPage> {
  List<String> _declinedBidIds = [];

  void _onBidDeclined(String bidId) {
    setState(() {
      _declinedBidIds.add(bidId);
    });
  }

  void _onBidAccepted(String shipmentId, String bidId) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      return; // If the user is not logged in, do nothing
    }

    final String currentUserId = currentUser.uid;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final WriteBatch batch = firestore.batch();

    final QuerySnapshot<Map<String, dynamic>> bidSnapshot = await firestore
        .collection('bids')
        .where('shipmentId', isEqualTo: shipmentId)
        .get();

    final now = DateTime.now();

    for (final DocumentSnapshot<Map<String, dynamic>> bidDocument
        in bidSnapshot.docs) {
      final Map<String, dynamic>? bidData = bidDocument.data();

      if (bidData != null) {
        final String currentBidId = bidDocument.id;
        final int bidPrice = bidData['price'] as int;
        final String bidDate = bidData['date'] as String;

        if (currentBidId == bidId) {
          // Fetch the courierId from the bids collection
          final String courierId = bidData['courierId'] as String;

          // Store accepted bid in acceptedBids collection
          final acceptedBidRef = firestore.collection('acceptedBids').doc();
          batch.set(acceptedBidRef, {
            'bidId': bidId,
            'courierId': courierId,
            'userId': currentUserId,
            'price': bidPrice,
            'date': bidDate,
            'shipmentId': shipmentId,
          });

          // Modify the shipment document in the shipments collection
          final shipmentRef = firestore.collection('shipments').doc(shipmentId);
          batch.update(shipmentRef, {
            'courierId': courierId,
            // Include any other fields you want to update in the shipment document
          });
        } else {
          // Move other bids to declinedBids collection
          final declinedBidRef =
              firestore.collection('declinedBids').doc(currentBidId);
          batch.set(declinedBidRef, {
            'bidId': currentBidId,
            'courierId':
                bidData['courierId'] as String, // Use the original courierId
            'userId': currentUserId,
            'price': bidPrice,
            'date': bidDate,
            'shipmentId': shipmentId,
          });
        }

        // Delete bid from bids collection
        batch.delete(bidDocument.reference);
      }
    }

    batch.commit().then((_) {
      // Show a confirmation snackbar
      ElegantNotification.success(
        title: Text('Bid Accepted'),
        description: Text('Thank you for accepting a bid.'),
        notificationPosition: NotificationPosition.topCenter,
        animation: AnimationType.fromTop,
        // icon: Icon(Icons.check),
        // color: Colors.green,
      ).show(context);
    }).catchError((error) {
      // Show an error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting bid: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    final String currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bids'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.size,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot<Map<String, dynamic>> document =
                  snapshot.data!.docs[index];
              final Map<String, dynamic>? data = document.data();

              if (data == null) {
                // Skip rendering if data is null
                return SizedBox.shrink();
              }

              final String bidId = document.id;
              final String courierId = data['courierId'] as String;
              final int bidPrice = data['price'] as int;
              final String bidDate = data['date'] as String;
              final String shipmentId = data['shipmentId'] as String;

              if (_declinedBidIds.contains(bidId)) {
                // Skip rendering if the bid was declined
                return SizedBox.shrink();
              }

              return Card(
                elevation: 2,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListTile(
                    title: Text('Shipment ID: $shipmentId'),
                    subtitle:
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(courierId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasData) {
                          final Map<String, dynamic>? userData =
                              snapshot.data!.data();
                          if (userData != null) {
                            final String firstName =
                                userData['firstName'] as String;
                            final String lastName =
                                userData['lastName'] as String;
                            final double overallRating =
                                userData['overallRating'] as double;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Courier Name: $firstName $lastName'),
                                Text(
                                    'Overall Rating: ${overallRating.toStringAsFixed(2)}'),
                                Text('Price: $bidPrice'),
                                Text('Date: $bidDate'),
                              ],
                            );
                          }
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: () {
                            _onBidAccepted(shipmentId, bidId);
                          },
                          style: FilledButton.styleFrom(
                              fixedSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text('Accept'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _onBidDeclined(bidId);
                            BidOperations.declineBid(context, bidId, courierId,
                                bidPrice, bidDate, shipmentId);
                          },
                          style: FilledButton.styleFrom(
                              fixedSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text('Decline'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
