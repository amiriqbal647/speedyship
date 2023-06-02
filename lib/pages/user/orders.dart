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
                OrderList(status: 'pending'),
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

            return Card(
              margin: const EdgeInsets.all(15.0),
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
                    const SizedBox(
                      height: 10.0,
                    ),
                    FilledButton(
                      onPressed: () {
                        _showRatingDialog(context, shipmentId, courierId);
                      },
                      style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      child: const Text("Rate Courier"),
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
                  'comments': commentController.text,
                };

                FirebaseFirestore.instance
                    .collection('ratings')
                    .add(ratingData);

                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
