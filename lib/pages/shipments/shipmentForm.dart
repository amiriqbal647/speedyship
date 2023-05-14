import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speedyship/pages/shipments/summary_page.dart';

import '../homepage.dart';
import '../location.dart';

class ShipmentInformation extends StatefulWidget {
  @override
  State<ShipmentInformation> createState() => _ShipmentInformationState();
}

class _ShipmentInformationState extends State<ShipmentInformation> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static List<String> _CategoryList = [
    "Food",
    "Electronics",
    "Clothes",
    "Documents"
  ];
  static List<String> _cityList = [
    "Famagusta",
    "Nicosia",
    "Karpas",
    "Kerniya",
    "Lefke",
    "Morphou"
  ];
  String _selectedVal2 = _cityList.first;
  String _selectedVal = _CategoryList.first;

  final weightController = TextEditingController();
  final lengthController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final _myLocationController = TextEditingController();
  final _destinationController = TextEditingController();
  final recipientcontroller = TextEditingController();
  final recipientphonecontroller = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        final userId = user?.uid;
        await FirebaseFirestore.instance.collection('shipments').add({
          'RecipientName': recipientcontroller.text.trim(),
          'RecipientPhone': recipientphonecontroller.text,
          'category': _selectedVal,
          'weight': int.tryParse(weightController.text) ?? 0,
          'length': int.tryParse(lengthController.text) ?? 0,
          'width': int.tryParse(widthController.text) ?? 0,
          'height': int.tryParse(heightController.text) ?? 0,
          'city': _selectedVal2,
          'location': _myLocationController.text,
          'destination': _destinationController.text,
          'userId': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shipment added successfully')),
        );
        // Go back to previous screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add shipment')),
        );
        print('Failed to add shipment: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Shipment Information',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(children: [
          Form(
            key: _formKey,
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shipment Details container
                      Text(
                        'Shipment details',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade600,
                                  spreadRadius: 1,
                                  blurRadius: 15)
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(
                              children: [
                                //Category
                                DropdownButtonFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedVal = val!;
                                    });
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Category'),
                                  items: _CategoryList.map((item) {
                                    return DropdownMenuItem(
                                      child: Text(item),
                                      value: item,
                                    );
                                  }).toList(),
                                  value: _selectedVal,
                                  icon: Icon(Icons.keyboard_arrow_down_sharp),
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Recipients Name',
                                    suffixIcon: Icon(Icons.person),
                                  ),
                                  controller: recipientcontroller,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Recipients Phone Number',
                                    suffixIcon: Icon(Icons.phone),
                                  ),
                                  controller: recipientphonecontroller,
                                  keyboardType: TextInputType.phone,
                                ),
                                //Weight
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a weight";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.line_weight),
                                      labelText: "Weight"),
                                  controller: weightController,
                                ),

                                //Length & height
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: // Length
                                          TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Plese enter a length";
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.straighten),
                                            labelText: "Length"),
                                        controller: lengthController,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Flexible(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please enter a width";
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.straighten),
                                            labelText: "Width"),
                                        controller: widthController,
                                      ),
                                    ),
                                  ],
                                ),

                                // Height

                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a height";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  //initialValue: "100cm",
                                  decoration: InputDecoration(
                                      suffixIcon: Icon(Icons.straighten),
                                      labelText: "Height"),
                                  controller: heightController,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Shipping Address
                      Text(
                        'Shipping address',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade600,
                                  spreadRadius: 1,
                                  blurRadius: 15)
                            ],
                          ),
                          //padding: EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: Column(children: [
                              // City
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: "City",
                                ),
                                items: _cityList.map((item) {
                                  return DropdownMenuItem(
                                    child: Text(item),
                                    value: item,
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedVal2 = val!;
                                  });
                                },
                                value: _selectedVal2,
                                icon: Icon(Icons.keyboard_arrow_down_sharp),
                              ),

                              // My Location
                              TextFormField(
                                readOnly: true,
                                onTap: () async {
                                  String? selectedAddress =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectLocation(),
                                    ),
                                  );
                                  if (selectedAddress != null) {
                                    _myLocationController.text =
                                        selectedAddress;
                                  }
                                },
                                decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.home_filled),
                                    labelText: 'My Location'),
                                controller: _myLocationController,
                              ),

                              //Destination
                              TextFormField(
                                readOnly: true,
                                onTap: () async {
                                  String? selectedAddress =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectLocation(),
                                    ),
                                  );
                                  if (selectedAddress != null) {
                                    _destinationController.text =
                                        selectedAddress;
                                  }
                                },
                                decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.location_on),
                                    labelText: 'Destination'),
                                controller: _destinationController,
                              ),
                            ]),
                          ),
                        ),
                      ),

                      // Continue button

                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SummaryPage(
                                          category: _selectedVal,
                                          weight: int.tryParse(
                                                  weightController.text) ??
                                              0,
                                          length: int.tryParse(
                                                  lengthController.text) ??
                                              0,
                                          width: int.tryParse(
                                                  widthController.text) ??
                                              0,
                                          height: int.tryParse(
                                                  heightController.text) ??
                                              0,
                                          city: _selectedVal2,
                                          location: _myLocationController.text,
                                          destination:
                                              _destinationController.text,
                                          recphone:
                                              recipientphonecontroller.text,
                                          recname: recipientcontroller.text,
                                        )),
                              );
                            }
                          },
                          child: Text('Continue'),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(350, 60),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}
