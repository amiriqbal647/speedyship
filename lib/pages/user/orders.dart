import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OrderList(status: 'approval_pending'),
                OrderList(status: 'delivered'),
                OrderList(status: 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final shipment = documents[index].data() as Map<String, dynamic>;
            final shipmentId = documents[index].id;
            final location = shipment['location'] as String? ?? '';
            final destination = shipment['destination'] as String? ?? '';
            final courierId = shipment['courierId'] as String? ?? '';
            final shipmentStatus = shipment['status'] as String? ?? '';

            return Card(
              margin: const EdgeInsets.all(15.0),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment ID: $shipmentId',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      'Location: $location',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      'Destination: $destination',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    const SizedBox(height: 10.0),
                    if (status == 'approval_pending' &&
                        shipmentStatus == 'approval_pending')
                      ElevatedButton(
                        onPressed: () {
                          _confirmDelivery(context, shipmentId);
                        },
                        child: const Text("Approve"),
                      )
                    else
                      IgnorePointer(
                        ignoring: true,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text("Approve"),
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _checkAndShowRatingDialog(
                            context, shipmentId, courierId);
                      },
                      child: const Text("Rate Courier"),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _showSupportDialog(context);
                      },
                      child: const Text("Support"),
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

    if (ratingsSnapshot.docs.isNotEmpty) {
      // User has already rated the courier for this shipment
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rating Error"),
            content:
                Text("You have already rated the courier for this shipment."),
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
      return; // Exit the method
    }

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
            ElevatedButton(
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
