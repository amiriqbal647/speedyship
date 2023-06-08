import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:speedyship/components/date_picker2.dart';

class CourierBidsForm extends StatefulWidget {
  final String userId;

  final String shipmentId;

  const CourierBidsForm({required this.userId, required this.shipmentId});

  @override
  _CourierBidsFormState createState() => _CourierBidsFormState();
}

class _CourierBidsFormState extends State<CourierBidsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController priceController = TextEditingController();

  DateTime? dateController;

  _CourierBidsFormState() {
    dateController = DateTime.now();
  }

  Future<void> submitBid(BuildContext context) async {
    final int price = int.tryParse(priceController.text) ?? 0;

    final String selectedUserId = widget.userId;

    final String shipmentId = widget.shipmentId;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(selectedUserId)
        .get();

    final String selectedUsername =
        '${userData.get('firstName')} ${userData.get('lastName')}';

    final FirebaseAuth auth = FirebaseAuth.instance;

    final User? currentUser = auth.currentUser;

    if (currentUser != null) {
      final String currentUserId = currentUser.uid;

      final String bidId =
          FirebaseFirestore.instance.collection('bids').doc().id;

      final dateControllerr =
          dateController != null ? dateController!.toIso8601String() : null;

      if (dateControllerr == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please select a date.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );

        return;
      }

      await FirebaseFirestore.instance.collection('bids').doc(bidId).set({
        'courierId': currentUserId,
        'userId': selectedUserId,
        'shipmentId': shipmentId,
        'price': price,
        'date': dateControllerr,
      });

      priceController.clear();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomThankYouDialog();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courier Bid"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Add Your Bid",
                    style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 24.0),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.transparent, width: 0),
                      ),
                      filled: true,
                      hintText: 'Price'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price.';
                    }

                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                MyDatePickerTwo(
                  onDateSelected: (date) =>
                      setState(() => dateController = date),
                ),
                const SizedBox(height: 16.0),
                //submit button
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      submitBid(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                      fixedSize: const Size(360, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomThankYouDialog extends StatelessWidget {
  const CustomThankYouDialog({Key? key}) : super(key: key);

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
                'Your application has been submitted. Please wait until the admin approves your request.',
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0.0,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      child: _buildDialogContent(context),
    );
  }
}
