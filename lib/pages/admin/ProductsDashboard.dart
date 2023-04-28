import 'package:flutter/material.dart';

enum Status {
  delivered,
  canceled,
  pending,
}

class User {
  final String? shipmentId;
  final String? userName;
  final double? weight;
  final String? pickUp;
  final String? destination;
  final Status? status;

  User(this.shipmentId, this.userName, this.weight, this.pickUp,
      this.destination, this.status);
}

class ProductsDashboard extends StatefulWidget {
  @override
  _ProductsDashboardState createState() => _ProductsDashboardState();
}

class _ProductsDashboardState extends State<ProductsDashboard> {
  List<User> users = [
    User('#2521', 'REIAD ALARBI', 5.0, 'Los Angeles', 'New York',
        Status.pending),
    User('#2342', 'IBRAHEM ALI', 3.5, 'San Francisco', 'Chicago',
        Status.pending),
    User('#2433', 'AMIR SOMETHING', 10.0, 'Houston', 'Miami', Status.delivered),
    User('#3424', 'YUSEF MOHAMMADEAN', 7.5, 'Seattle', 'Boston',
        Status.delivered),
    User('#5425', 'AMRO ZAHAR', 2.0, 'Dallas', 'Atlanta', Status.canceled),
  ];

  void deleteUser(User user) {
    setState(() {
      users.remove(user);
    });
  }

  Color getStatusColor(Status status) {
    switch (status) {
      case Status.delivered:
        return Colors.blue;
      case Status.canceled:
        return Colors.red;
      case Status.pending:
      default:
        return Colors.yellow;
    }
  }

  String getStatusText(Status status) {
    switch (status) {
      case Status.delivered:
        return 'Delivered';
      case Status.canceled:
        return 'Canceled';
      case Status.pending:
      default:
        return 'Pending';
    }
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
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipment ID: ${user.shipmentId ?? ""}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'User: ${user.userName ?? ""}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Weight: ${user.weight?.toString() ?? ""} kg',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pick up: ${user.pickUp ?? ""}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Destination: ${user.destination ?? ""}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor(
                                      user.status ?? Status.pending),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                getStatusText(user.status ?? Status.pending),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Color.fromARGB(255, 222, 114, 25)),
                      onPressed: () {
                        deleteUser(user);
                      },
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
