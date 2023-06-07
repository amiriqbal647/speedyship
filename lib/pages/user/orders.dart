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

class OrderList extends StatelessWidget {
  final dynamic status;

  OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shipments')
          .where('status', whereIn: status is List ? status : [status])
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

            final bool isDisabled =
                (status == 'cancelled' || status == 'delivered') ||
                    (status is List && status.contains(shipmentStatus));

            bool isConfirmDeliveryEnabled = (status.contains('pending') ||
                    status.contains('approval_pending')) &&
                (shipmentStatus == 'pending' ||
                    shipmentStatus == 'approval_pending');

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
                    const SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                      onPressed: isConfirmDeliveryEnabled
                          ? () {
                              _confirmDelivery(context, shipmentId);
                            }
                          : null,
                      child: const Text("Confirm Delivery"),
                      style: ElevatedButton.styleFrom(
                        primary: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        _showRatingDialog(context, shipmentId, courierId);
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
    // Rating dialog code here
  }

  void _showSupportDialog(BuildContext context) {
    // Support dialog code here
  }
}
