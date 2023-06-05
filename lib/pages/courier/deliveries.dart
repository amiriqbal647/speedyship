import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Delivery {
  final String location;
  final String destination;
  final String shipmentId;
  String status;

  Delivery({
    required this.location,
    required this.destination,
    required this.shipmentId,
    required this.status,
  });
}

class DeliveriesPage extends StatefulWidget {
  @override
  _DeliveriesPageState createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Delivery>> _pendingDeliveries;
  late Future<List<Delivery>> _completedDeliveries;
  late Future<List<Delivery>> _cancelledDeliveries;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _tabController = TabController(length: 3, vsync: this);
    _pendingDeliveries = fetchDeliveries(['pending', 'approval_pending']);
    _completedDeliveries = fetchDeliveries(['delivered']);
    _cancelledDeliveries = fetchDeliveries(['cancelled']);
    loadPendingDeliveries();
  }

  Future<void> loadPendingDeliveries() async {
    try {
      List<Delivery> deliveries =
          await fetchDeliveries(['pending', 'approval_pending']);
      setState(() {
        _pendingDeliveries = Future<List<Delivery>>.value(deliveries);
      });
    } catch (error) {
      setState(() {
        _pendingDeliveries = Future<List<Delivery>>.error(error);
      });
    }
  }

  Future<List<Delivery>> fetchDeliveries(List<String> statuses) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not authenticated
      return [];
    }

    final String courierId = user.uid;

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('shipments')
        .where('status', whereIn: statuses)
        .where('courierId', isEqualTo: courierId)
        .get();

    List<Delivery> deliveries = [];

    querySnapshot.docs.forEach((doc) {
      deliveries.add(
        Delivery(
          location: doc['location'],
          destination: doc['destination'],
          shipmentId: doc.id,
          status: doc['status'],
        ),
      );
    });

    return deliveries;
  }

  Future<void> updateDeliveryStatus(
    String shipmentId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('shipments')
          .doc(shipmentId)
          .update({'status': status});
    } catch (error) {
      print('Error updating delivery status: $error');
    }
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
        title: Text('Deliveries'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildDeliveryList(
            _pendingDeliveries,
            'No pending deliveries',
            true,
            true,
          ),
          buildDeliveryList(
            _completedDeliveries,
            'No completed deliveries',
            false,
            false,
          ),
          buildDeliveryList(
            _cancelledDeliveries,
            'No cancelled deliveries',
            false,
            true,
          ),
        ],
      ),
    );
  }

  Widget buildDeliveryList(
    Future<List<Delivery>> deliveries,
    String emptyMessage,
    bool showCompleteButton,
    bool showCancelButton,
  ) {
    return FutureBuilder<List<Delivery>>(
      future: deliveries,
      builder: (BuildContext context, AsyncSnapshot<List<Delivery>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error fetching deliveries'));
        }
        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMessage));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (BuildContext context, int index) {
            Delivery delivery = snapshot.data![index];
            return Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Location: ${delivery.location}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Destination: ${delivery.destination}'),
                        Text('Shipment ID: ${delivery.shipmentId}'),
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      if (showCompleteButton)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Complete Delivery'),
                                  content: Text(
                                    'Are you sure you want to complete this delivery?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        updateDeliveryStatus(
                                          delivery.shipmentId,
                                          'approval_pending',
                                        );
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text('Complete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Complete Delivery'),
                        ),
                      if (showCancelButton)
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Cancel Delivery'),
                                  content: Text(
                                    'Are you sure you want to cancel this delivery?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        updateDeliveryStatus(
                                          delivery.shipmentId,
                                          'cancelled',
                                        );
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: Text('Yes, Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Cancel'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle support button click
                          // Replace with your own logic
                          print('Support clicked');
                        },
                        child: Text('Support'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DeliveriesPage(),
  ));
}
