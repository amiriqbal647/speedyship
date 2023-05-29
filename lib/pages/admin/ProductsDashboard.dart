import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Shipment {
  final String shipmentId;
  final String userName;
  final double weight;
  final String pickUp;
  final String destination;

  Shipment({
    required this.shipmentId,
    required this.userName,
    required this.weight,
    required this.pickUp,
    required this.destination,
  });
}

class ProductsDashboard extends StatefulWidget {
  @override
  _ProductsDashboardState createState() => _ProductsDashboardState();
}

class _ProductsDashboardState extends State<ProductsDashboard> {
  List<Shipment> shipments = [];

  @override
  void initState() {
    super.initState();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('shipments').get();

    final List<Shipment> shipments = snapshot.docs.map((doc) {
      final userData = doc.data();
      return Shipment(
        shipmentId: doc.id,
        userName: userData?['RecipientName'] as String? ?? '',
        weight: (userData?['weight'] as num?)?.toDouble() ?? 0.0,
        pickUp: userData?['pickUp'] as String? ?? '',
        destination: userData?['destination'] as String? ?? '',
      );
    }).toList();

    setState(() {
      this.shipments = shipments;
    });
  }

  void deleteShipment(Shipment shipment) {
    FirebaseFirestore.instance
        .collection('shipments')
        .doc(shipment.shipmentId)
        .delete();

    setState(() {
      shipments.remove(shipment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(9, 147, 120, 1.0),
        title: Text('Products Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: shipments.length,
          itemBuilder: (context, index) {
            final shipment = shipments[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipment ID: ${shipment.shipmentId}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'User: ${shipment.userName}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Weight: ${shipment.weight.toString()} kg',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pick up: ${shipment.pickUp}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Destination: ${shipment.destination}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 222, 114, 25),
                        ),
                        onPressed: () {
                          deleteShipment(shipment);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
