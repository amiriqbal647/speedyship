import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:speedyship/components/my_textfield.dart';
import 'package:speedyship/pages/shipments/summary_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
      appBar: AppBar(title: const Text('Shipment Information')),
      body: ListView(children: [
        Form(
          key: _formKey,
          child: Device.screenType == ScreenType.tablet
              ?
              //Desktop View************************************************************
              Center(
                  child: SizedBox(
                    width: 50.w,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          //Shipment Details card
                          Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  //Shipment details
                                  Text(
                                    'Shipment details',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //Category
                                  DropdownButtonFormField(
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedVal = val!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                        filled: true,
                                        labelText: 'Category'),
                                    items: _CategoryList.map((item) {
                                      return DropdownMenuItem(
                                        child: Text(item),
                                        value: item,
                                      );
                                    }).toList(),
                                    value: _selectedVal,
                                    icon: Icon(Icons.keyboard_arrow_down_sharp),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //Recipient Name
                                  MyTextField(
                                    controller: recipientcontroller,
                                    hintText: 'Recipient name',
                                    obscureText: false,
                                    keyboardType: TextInputType.name,
                                    readOnly: false,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a name';
                                      } else if (!RegExp(r'^[a-zA-Z]{1,20}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid name with maximum 20 letters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //Recipient phone no
                                  MyTextField(
                                    controller: recipientphonecontroller,
                                    hintText: 'Recipient phone number',
                                    obscureText: false,
                                    keyboardType: TextInputType.phone,
                                    readOnly: false,
                                    // placeholder: '',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a phone number';
                                      } else if (!RegExp(
                                              r'^\+90\s(5\d{2})\s(\d{3})\s(\d{4})$')
                                          .hasMatch(value)) {
                                        return 'the format of the number should be +90 5xx xxx xxxx';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //Weight
                                  MyTextField(
                                    controller: weightController,
                                    hintText: 'Weight',
                                    obscureText: false,
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.allow(
                                    //       RegExp(r'[0-9]')),
                                    // ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter a weight";
                                      } else if (double.tryParse(value) ==
                                              null ||
                                          double.parse(value) > 50) {
                                        return "Please enter a valid weight less than or equal to 50";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //Length & height
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: // Length
                                            MyTextField(
                                          controller: lengthController,
                                          hintText: 'length',
                                          obscureText: false,
                                          readOnly: false,
                                          keyboardType: TextInputType.number,
                                          // inputFormatters: [
                                          //   FilteringTextInputFormatter.allow(
                                          //       RegExp(r'[0-9]')),
                                          // ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter a length";
                                            } else if (double.tryParse(value) ==
                                                    null ||
                                                double.parse(value) > 50) {
                                              return "Please enter a valid length less than or equal to 50";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Flexible(
                                        //width
                                        child: MyTextField(
                                          controller: widthController,
                                          hintText: 'Width',
                                          obscureText: false,
                                          readOnly: false,
                                          keyboardType: TextInputType.number,
                                          // inputFormatters: [
                                          //   FilteringTextInputFormatter.allow(
                                          //       RegExp(r'[0-9]')),
                                          // ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter a width";
                                            } else if (double.tryParse(value) ==
                                                    null ||
                                                double.parse(value) > 50) {
                                              return "Please enter a valid width less than or equal to 50";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  // Height
                                  MyTextField(
                                    controller: heightController,
                                    hintText: 'Height',
                                    obscureText: false,
                                    readOnly: false,
                                    keyboardType: TextInputType.number,
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.allow(
                                    //       RegExp(r'[0-9]')),
                                    // ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter a Height";
                                      } else if (double.tryParse(value) ==
                                              null ||
                                          double.parse(value) > 50) {
                                        return "Please enter a valid Height less than or equal to 50";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),

                          // Shipping Address card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(children: [
                                //Shipping address
                                Text(
                                  'Shipping address',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                // City
                                DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent,
                                            width: 0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent,
                                            width: 0)),
                                    filled: true,
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
                                const SizedBox(
                                  height: 15.0,
                                ),

                                // My Location
                                MyTextField(
                                  controller: _myLocationController,
                                  hintText: 'Location',
                                  obscureText: false,
                                  keyboardType: TextInputType.none,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please fill the location field";
                                    }
                                  },
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
                                ),
                                const SizedBox(
                                  height: 15.0,
                                ),

                                //Destination
                                MyTextField(
                                  controller: _destinationController,
                                  hintText: 'Destination',
                                  obscureText: false,
                                  keyboardType: TextInputType.none,
                                  readOnly: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please fill the destination field";
                                    }
                                  },
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
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),

                          // Continue button
                          Center(
                            child: MyButton(
                              buttonText: 'Continue',
                              onTap: () {
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
                                              location:
                                                  _myLocationController.text,
                                              destination:
                                                  _destinationController.text,
                                              recphone:
                                                  recipientphonecontroller.text,
                                              recname: recipientcontroller.text,
                                            )),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              :
              //Mobile view************************************************************
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      //Shipment Details card
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              //Shipment details
                              Text(
                                'Shipment details',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //Category
                              DropdownButtonFormField(
                                onChanged: (val) {
                                  setState(() {
                                    _selectedVal = val!;
                                  });
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent,
                                            width: 0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent,
                                            width: 0)),
                                    filled: true,
                                    labelText: 'Category'),
                                items: _CategoryList.map((item) {
                                  return DropdownMenuItem(
                                    child: Text(item),
                                    value: item,
                                  );
                                }).toList(),
                                value: _selectedVal,
                                icon: Icon(Icons.keyboard_arrow_down_sharp),
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //Recipient Name
                              MyTextField(
                                controller: recipientcontroller,
                                hintText: 'Recipient name',
                                obscureText: false,
                                keyboardType: TextInputType.name,
                                readOnly: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a name';
                                  } else if (!RegExp(r'^[a-zA-Z]{1,20}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid name with maximum 20 letters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //Recipient phone no
                              MyTextField(
                                controller: recipientphonecontroller,
                                hintText: 'Recipient phone number',
                                obscureText: false,
                                keyboardType: TextInputType.phone,
                                readOnly: false,
                                // placeholder: '',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a phone number';
                                  } else if (!RegExp(
                                          r'^\+90\s(5\d{2})\s(\d{3})\s(\d{4})$')
                                      .hasMatch(value)) {
                                    return 'the format of the number should be +90 5xx xxx xxxx';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //Weight
                              MyTextField(
                                controller: weightController,
                                hintText: 'Weight',
                                obscureText: false,
                                readOnly: false,
                                keyboardType: TextInputType.number,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //       RegExp(r'[0-9]')),
                                // ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a weight";
                                  } else if (double.tryParse(value) == null ||
                                      double.parse(value) > 50) {
                                    return "Please enter a valid weight less than or equal to 50";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 15,
                              ),

                              //Length & height
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: // Length
                                        MyTextField(
                                      controller: lengthController,
                                      hintText: 'length',
                                      obscureText: false,
                                      readOnly: false,
                                      keyboardType: TextInputType.number,
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter.allow(
                                      //       RegExp(r'[0-9]')),
                                      // ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a length";
                                        } else if (double.tryParse(value) ==
                                                null ||
                                            double.parse(value) > 50) {
                                          return "Please enter a valid length less than or equal to 50";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Flexible(
                                    //width
                                    child: MyTextField(
                                      controller: widthController,
                                      hintText: 'Width',
                                      obscureText: false,
                                      readOnly: false,
                                      keyboardType: TextInputType.number,
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter.allow(
                                      //       RegExp(r'[0-9]')),
                                      // ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a width";
                                        } else if (double.tryParse(value) ==
                                                null ||
                                            double.parse(value) > 50) {
                                          return "Please enter a valid width less than or equal to 50";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              // Height
                              MyTextField(
                                controller: heightController,
                                hintText: 'Height',
                                obscureText: false,
                                readOnly: false,
                                keyboardType: TextInputType.number,
                                // inputFormatters: [
                                //   FilteringTextInputFormatter.allow(
                                //       RegExp(r'[0-9]')),
                                // ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a Height";
                                  } else if (double.tryParse(value) == null ||
                                      double.parse(value) > 50) {
                                    return "Please enter a valid Height less than or equal to 50";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),

                      // Shipping Address card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(children: [
                            //Shipping address
                            Text(
                              'Shipping address',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // City
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 0)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 0)),
                                filled: true,
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
                            const SizedBox(
                              height: 15.0,
                            ),

                            // My Location
                            MyTextField(
                              controller: _myLocationController,
                              hintText: 'Location',
                              obscureText: false,
                              keyboardType: TextInputType.none,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill the location field";
                                }
                              },
                              onTap: () async {
                                String? selectedAddress = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectLocation(),
                                  ),
                                );
                                if (selectedAddress != null) {
                                  _myLocationController.text = selectedAddress;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),

                            //Destination
                            MyTextField(
                              controller: _destinationController,
                              hintText: 'Destination',
                              obscureText: false,
                              keyboardType: TextInputType.none,
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please fill the destination field";
                                }
                              },
                              onTap: () async {
                                String? selectedAddress = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectLocation(),
                                  ),
                                );
                                if (selectedAddress != null) {
                                  _destinationController.text = selectedAddress;
                                }
                              },
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),

                      // Continue button
                      Center(
                        child: MyButton(
                          buttonText: 'Continue',
                          onTap: () {
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
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
