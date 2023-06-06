import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bid_operations.dart';

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
            'status': 'pending', // Update the status field to "pending"
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
      // Show a confirmation notification
      ElegantNotification.success(
        title: Text('Bid Accepted'),
        description: Text('Thank you for accepting a bid.'),
        notificationPosition: NotificationPosition.topCenter,
        animation: AnimationType.fromTop,
        // icon: Icon(Icons.check),
        // color: Colors.green,
      ).show(context);
    }).catchError((error) {
      // Show an error notification
      ElegantNotification.error(
        title: Text('Error Accepting Bid'),
        description: Text('Error accepting bid: $error'),
        // icon: Icon(Icons.error),
        // color: Colors.red,
      ).show(context);
    });
  }

  Future<Map<String, dynamic>?> _getUserData(String courierId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(courierId)
        .get();
    return snapshot.data() as Map<String, dynamic>?;
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

class OrderList extends StatelessWidget {
  final String status;

  OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shipments')
          .where('status', isEqualTo: status)
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
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

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserData(courierId),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>?> userDataSnapshot) {
                  if (userDataSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox
                        .shrink(); // Show a loading indicator if user data is still loading
                  }

                  final userData = userDataSnapshot.data;
                  final firstName = userData?['firstName'] as String? ?? '';
                  final lastName = userData?['lastName'] as String? ?? '';
                  final overallRating =
                      userData?['overallRating'] as double? ?? 0.0;

            return Card(
              margin: const EdgeInsets.all(12.0),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment ID: $shipmentId',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Location: $location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Destination: $destination',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10.0),
                    if (status == 'approval_pending' &&
                        shipmentStatus == 'approval_pending')
                      ElevatedButton(
                        onPressed: () {
                          _onBidAccepted(shipmentId, bidId);
                        },
                      ),
                      onTap: () {
                        _onBidDeclined(bidId);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelivery(BuildContext context, String shipmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delivery"),
          content:
              Text("Are you sure you want to mark this shipment as delivered?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Update the status to "delivered" in Firestore
                FirebaseFirestore.instance
                    .collection('shipments')
                    .doc(shipmentId)
                    .update({'status': 'delivered'});

                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _checkAndShowRatingDialog(
      BuildContext context, String shipmentId, String courierId) async {
    // Check if the user has already rated the courier for this shipment
    final user = FirebaseAuth.instance.currentUser;
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('userId', isEqualTo: user!.uid)
        .where('shipmentId', isEqualTo: shipmentId)
        .limit(1)
        .get();

    // if (ratingsSnapshot.docs.isNotEmpty) {
    //   // User has already rated the courier for this shipment
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text("Rating Error"),
    //         content:
    //             Text("You have already rated the courier for this shipment."),
    //         actions: [
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: Text("OK"),
    //           ),
    //         ],
    //       );
    //     },
    //   );
    //   return; // Exit the method
    // }

    _showRatingDialog(context, shipmentId, courierId);
  }

  void _showRatingDialog(
      BuildContext context, String shipmentId, String courierId) {
    final ratingController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rate Courier"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: "Comments",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                final ratingData = {
                  'userId': FirebaseAuth.instance.currentUser!.uid,
                  'shipmentId': shipmentId,
                  'courierId': courierId,
                  'rating': rating,
                  'comment': commentController.text,
                };

                // Add the rating data to the 'ratings' collection in Firestore
                FirebaseFirestore.instance
                    .collection('ratings')
                    .add(ratingData)
                    .then((_) {
                  // Update the courier's overall rating
                  _updateCourierOverallRating(courierId, rating);

                  Navigator.of(context).pop();
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Rating Error"),
                        content: Text(
                          "An error occurred while submitting your rating. Please try again later.",
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                });
              },
              child: Text("Submit"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _updateCourierOverallRating(String courierId, double newRating) {
    final ratingsRef = FirebaseFirestore.instance.collection('ratings');
    final courierRatingsQuery =
        ratingsRef.where('courierId', isEqualTo: courierId);

    courierRatingsQuery.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        int totalRatings = snapshot.docs.length;

        for (var doc in snapshot.docs) {
          final ratingData = doc.data() as Map<String, dynamic>;
          final rating = ratingData['rating'] as double;
          totalRating += rating;
        }

        final overallRating = totalRating / totalRatings;

        // Update the overallRating field in the courier's document
        FirebaseFirestore.instance
            .collection('users')
            .doc(courierId)
            .update({'overallRating': overallRating});
      }
    });
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Support"),
          content: Text("For support, please contact our customer service."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
