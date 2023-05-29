import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourierRatingsPage extends StatefulWidget {
  @override
  _CourierRatingsPageState createState() => _CourierRatingsPageState();
}

class _CourierRatingsPageState extends State<CourierRatingsPage> {
  late Future<double> _overallRating;
  late String courierId;

  @override
  void initState() {
    super.initState();
    courierId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _overallRating = calculateOverallRating();
  }

  Future<double> calculateOverallRating() async {
    final QuerySnapshot ratingSnapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('courierId', isEqualTo: courierId)
        .get();

    if (ratingSnapshot.docs.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    int ratingCount = 0;

    ratingSnapshot.docs.forEach((doc) {
      final rating = doc.data() as Map<String, dynamic>;
      final ratingValue = rating['rating'] as double?;
      if (ratingValue != null) {
        totalRating += ratingValue;
        ratingCount++;
      }
    });

    if (ratingCount == 0) {
      return 0.0;
    }

    return totalRating / ratingCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courier Ratings'),
      ),
      body: Column(
        children: [
          FutureBuilder<double>(
            future: _overallRating,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final overallRating = snapshot.data ?? 0.0;
              final formattedRating = overallRating.toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Overall Rating: $formattedRating',
                  style: TextStyle(fontSize: 20),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ratings')
                  .where('courierId', isEqualTo: courierId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final ratingData =
                        documents[index].data() as Map<String, dynamic>;
                    final userId = ratingData['userId'] as String? ?? '';
                    final shipmentId =
                        ratingData['shipmentId'] as String? ?? '';
                    final rating = ratingData['rating'] as double? ?? 0.0;
                    final comment = ratingData['comments'] as String? ?? '';

                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .get(),
                              builder: (context, snapshot) {
                                final userData = snapshot.data?.data()
                                    as Map<String, dynamic>?;

                                if (userData != null) {
                                  final firstName =
                                      userData['firstName'] as String? ?? '';
                                  final lastName =
                                      userData['lastName'] as String? ?? '';

                                  return Text('$firstName $lastName');
                                }

                                return Text(
                                    'N/A'); // Display a fallback value if userData is null
                              },
                            ),
                            Text('Shipment ID: $shipmentId'),
                            Text('Rating: $rating'),
                            Text('Comment: $comment'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
