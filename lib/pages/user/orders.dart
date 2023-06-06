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
          .where('status', whereIn: ['approval_pending', 'pending'])
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
                    if ((status == 'approval_pending' || status == 'pending') &&
                        (shipmentStatus == 'approval_pending' ||
                            shipmentStatus == 'pending'))
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
                    FilledButton(
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
    // Handle confirm delivery action
  }

  void _checkAndShowRatingDialog(
      BuildContext context, String shipmentId, String courierId) {
    // Handle checking and showing rating dialog
  }

  void _showSupportDialog(BuildContext context) {
    // Handle showing support dialog
  }
}

class FilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  FilledButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

extension TextStyleExtension on ThemeData {
  TextStyle get titleMedium => TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      );
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orders Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrdersPage(),
    );
  }
}
