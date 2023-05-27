import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            final shipmentId = shipment['shipmentId'] as String? ?? '';
            final location = shipment['location'] as String? ?? '';
            final destination = shipment['destination'] as String? ?? '';

            return Card(
              child: ListTile(
                title: Text('Shipment ID: $shipmentId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: $location'),
                    Text('Destination: $destination'),
                  ],
                ),
                // Add more order details here
              ),
            );
          },
        );
      },
    );
  }
}
