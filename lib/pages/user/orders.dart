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
                OrderList(status: ['pending', 'approval_pending']),
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

class OrderList extends StatefulWidget {
  final dynamic status;

  OrderList({required this.status});

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late Set<String> ratedShipments; // New line

  @override
  void initState() {
    super.initState();
    ratedShipments = {}; // Initialize the set
    fetchRatedShipments(); // Fetch rated shipments from Firestore
  }

  void fetchRatedShipments() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('userId', isEqualTo: uid)
        .get();

    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    setState(() {
      ratedShipments = Set.from(documents.map((doc) => doc['shipmentId']));
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shipments')
          .where('status',
              whereIn: widget.status is List ? widget.status : [widget.status])
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

            final bool isDisabled = (widget.status == 'cancelled') ||
                (widget.status is List &&
                    widget.status.contains(shipmentStatus));

            bool isConfirmDeliveryEnabled =
                (widget.status.contains('pending') ||
                        widget.status.contains('approval_pending')) &&
                    (shipmentStatus == 'pending' ||
                        shipmentStatus == 'approval_pending');

            bool isRateCourierEnabled =
                widget.status == 'delivered' && shipmentStatus == 'delivered';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.all(15.0),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment ID: $shipmentId',
                    ),
                    Text(
                      'Location: $location',
                    ),
                    Text(
                      'Destination: $destination',
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    FilledButton(
                      onPressed: isConfirmDeliveryEnabled
                          ? () {
                              _confirmDelivery(context, shipmentId);
                            }
                          : null,
                      child: const Text("Confirm Delivery"),
                      style: ElevatedButton.styleFrom(
                          primary: isDisabled ? Colors.grey : null,
                          fixedSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: isRateCourierEnabled &&
                              !ratedShipments
                                  .contains(shipmentId) // Updated condition
                          ? () {
                              _showRatingDialog(context, shipmentId, courierId);
                            }
                          : null,
                      child: const Text("Rate Courier"),
                      style: ElevatedButton.styleFrom(
                          primary: isDisabled ? Colors.grey : null,
                          fixedSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _showSupportDialog(context);
                      },
                      style: FilledButton.styleFrom(
                          fixedSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
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
            TextButton(
              onPressed: () {
                // Update the shipment status to "delivered"
                FirebaseFirestore.instance
                    .collection('shipments')
                    .doc(shipmentId)
                    .update({'status': 'delivered'});

                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
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
                  'comment': commentController.text,
                };

                FirebaseFirestore.instance
                    .collection('ratings')
                    .add(ratingData);

                setState(() {
                  ratedShipments.add(shipmentId); // Add shipmentId to the set
                });

                Navigator.of(context).pop();
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _showSupportDialog(BuildContext context) {
    // Support dialog code here
  }
}
