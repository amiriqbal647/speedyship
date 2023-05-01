import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import '../../components/dropdown_form_field.dart';
import '../../components/city_dropdown_form_field.dart';

class ShipmentForm extends StatefulWidget {
  ShipmentForm({Key? key}) : super(key: key);

  @override
  State<ShipmentForm> createState() => _ShipmentFormState();
}

class _ShipmentFormState extends State<ShipmentForm> {
  String _selectedOption = 'food'; // default option is 'food'
  String _citysSelectedOption = "magusa";

  final weightController = TextEditingController();

  final lengthController = TextEditingController();

  final widthController = TextEditingController();

  final heightController = TextEditingController();

  final locationController = TextEditingController();

  final destinationcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('shipments').add({
          'category': _selectedOption,
          'weight': int.tryParse(weightController.text) ?? 0,
          'length': int.tryParse(lengthController.text) ?? 0,
          'width': int.tryParse(widthController.text) ?? 0,
          'height': int.tryParse(heightController.text) ?? 0,
          'city': _citysSelectedOption,
          'location': locationController.text,
          'destination': destinationcontroller.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shipment added successfully')),
        );
        // clear form data after submission
        _selectedOption = 'food';
        _citysSelectedOption = 'magusa';
        weightController.clear();
        lengthController.clear();
        widthController.clear();
        heightController.clear();
        locationController.clear();
        destinationcontroller.clear();
        setState(() {});
        // Go back to previous screen
        Navigator.pop(context);
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
      appBar: AppBar(title: Text("shipment details")),
      body: ListView(
        children: [
          Column(
            children: [
              Text(
                "shipment details",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 25,
              ),
              MyDropdownButtonFormField(
                selectedOption: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value.toString();
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: weightController,
                hintText: 'weight',
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: lengthController,
                hintText: 'length',
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: widthController,
                hintText: 'width',
                obscureText: false,
              ),
              SizedBox(
                height: 10,
              ),
              MyTextField(
                controller: heightController,
                hintText: 'height',
                obscureText: false,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Shipping Address",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 20,
              ),
              MyCityDropdownButtonFormField(
                selectedOption: _citysSelectedOption,
                onChanged: (value) {
                  setState(() {
                    _citysSelectedOption = value.toString();
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: locationController,
                  hintText: 'Location',
                  obscureText: false),
              SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: destinationcontroller,
                  hintText: 'destination',
                  obscureText: false),
              ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: Text("Submit"))
            ],
          ),
        ],
      ),
    );
  }
}
