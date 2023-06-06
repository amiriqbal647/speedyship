import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SummaryPage extends StatelessWidget {
  final String category;
  final int weight;
  final int length;
  final int width;
  final int height;
  final String city;
  final String location;
  final String destination;
  final String recname;
  final String recphone;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SummaryPage({
    required this.category,
    required this.weight,
    required this.length,
    required this.width,
    required this.height,
    required this.city,
    required this.location,
    required this.destination,
    required this.recphone,
    required this.recname,
  });

  Future<void> _submitForm(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      final userId = user?.uid;
      await FirebaseFirestore.instance.collection('shipments').add({
        'RecipientName': this.recname,
        'RecipientPhone': this.recphone,
        'category': this.category,
        'weight': this.weight,
        'length': this.length,
        'width': this.width,
        'height': this.height,
        'city': this.city,
        'location': this.location,
        'destination': this.destination,
        'userId': userId,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _buildDialogContent(context),
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add shipment'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          );
        },
      );
      print('Failed to add shipment: $error');
    }
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 100,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Your request has been submitted, please wait for available couriers to bid',
                style: TextStyle(
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 45,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Summary'),
      ),
      body: SingleChildScrollView(
          child: Device.screenType == ScreenType.tablet
              ?
              //Desktop view***************************************************************************************
              Center(
                  child: SizedBox(
                    width: 50.w,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Shipment Summary',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // Category
                                  _buildSummaryItem('Category', category),
                                  // Weight
                                  _buildSummaryItem('Weight', '$weight kg'),
                                  // Dimensions
                                  _buildSummaryItem('Dimensions(L*W*H)',
                                      '$length x $width x $height'),
                                  _buildSummaryItem('Recipient Name', recname),
                                  _buildSummaryItem(
                                      'Recipients Phone Number', recphone),
                                  // City
                                  _buildSummaryItem('City', city),
                                  // Location
                                  _buildSummaryItem('Location', location),
                                  // Destination
                                  _buildSummaryItem('Destination', destination)
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Confirm Button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
                          child: MyButton(
                            buttonText: 'Confirm',
                            onTap: () => _submitForm(context),
                          ),
                        ),

                        // ElevatedButton(
                        //     onPressed: () => _submitForm(context),
                        //     child: const Text('Confirm'),
                        //     style: ElevatedButton.styleFrom(
                        //         fixedSize: Size(350, 60),
                        //         backgroundColor: Colors.orange,
                        //         shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(20))))
                      ],
                    ),
                  ),
                )
              :
              //Mobile view*****************************************************************8
              Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shipment Summary',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              // Category
                              _buildSummaryItem('Category', category),
                              // Weight
                              _buildSummaryItem('Weight', '$weight kg'),
                              // Dimensions
                              _buildSummaryItem('Dimensions(L*W*H)',
                                  '$length x $width x $height'),
                              _buildSummaryItem('Recipient Name', recname),
                              _buildSummaryItem(
                                  'Recipients Phone Number', recphone),
                              // City
                              _buildSummaryItem('City', city),
                              // Location
                              _buildSummaryItem('Location', location),
                              // Destination
                              _buildSummaryItem('Destination', destination)
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Confirm Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                      child: MyButton(
                        buttonText: 'Confirm',
                        onTap: () => _submitForm(context),
                      ),
                    ),

                    // ElevatedButton(
                    //     onPressed: () => _submitForm(context),
                    //     child: const Text('Confirm'),
                    //     style: ElevatedButton.styleFrom(
                    //         fixedSize: Size(350, 60),
                    //         backgroundColor: Colors.orange,
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(20))))
                  ],
                )),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(
          height: 10,
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Divider(
          height: 30,
        ),
      ],
    );
  }
}
