import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String dateOfBirth;

  EditProfilePage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.dateOfBirth,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  late String _firstName;
  late String _lastName;
  late String _email;
  late String _phoneNumber;
  late String _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _firstName = widget.firstName;
    _lastName = widget.lastName;
    _email = widget.email;
    _phoneNumber = widget.phoneNumber;
    _dateOfBirth = widget.dateOfBirth;
  }

  void updateUser() {
    usersRef.doc(widget.userId).update({
      'firstName': _firstName,
      'lastName': _lastName,
      'email': _email,
      'PhoneNumber': _phoneNumber,
      'DateOfBirth': _dateOfBirth,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit account')),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Device.screenType == ScreenType.tablet
                ?
                //Desktop view***********************************************************************
                Center(
                    child: SizedBox(
                      width: 50.w,
                      child: Column(
                        children: [
                          //Full name card
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            elevation: 2,
                            margin: const EdgeInsets.all(15),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Full name text
                                  Text(
                                    'Full name',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),

                                  //First name
                                  Text(
                                    'First name',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  buildTextFormField(_firstName, (value) {
                                    setState(() {
                                      _firstName = value;
                                    });
                                  }),
                                  const SizedBox(height: 10.0),

                                  //Last name
                                  Text(
                                    'Last name',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  buildTextFormField(_lastName, (value) {
                                    setState(() {
                                      _lastName = value;
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ),

                          // Email dob phone no card
                          Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            elevation: 2,
                            margin: const EdgeInsets.all(15.0),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Email
                                  Text(
                                    'Email',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  buildTextFormField(_email, (value) {
                                    setState(() {
                                      _email = value;
                                    });
                                  }, readOnly: true),
                                  const SizedBox(height: 10.0),

                                  //Phone number
                                  Text(
                                    'Phone number',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  buildTextFormField(_phoneNumber, (value) {
                                    setState(() {
                                      _phoneNumber = value;
                                    });
                                  }),
                                  const SizedBox(height: 10.0),
                                  //Date of birth
                                  Text(
                                    'Date of birth',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  buildTextFormField(_dateOfBirth, (value) {
                                    setState(() {
                                      _dateOfBirth = value;
                                    });
                                  }),
                                ],
                              ),
                            ),
                          ),

                          //Save chnages button
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: MyButton(
                              buttonText: 'Save changes',
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  updateUser();
                                  Navigator.pop(context,
                                      true); // Return true to indicate successful update
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                :
                //Mobile view**************************************************************************
                Column(
                    children: [
                      //Full name card
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        elevation: 2,
                        margin: const EdgeInsets.all(15),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Full name text
                              Text(
                                'Full name',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),

                              //First name
                              Text(
                                'First name',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              buildTextFormField(_firstName, (value) {
                                setState(() {
                                  _firstName = value;
                                });
                              }),
                              const SizedBox(height: 10.0),

                              //Last name
                              Text(
                                'Last name',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              buildTextFormField(_lastName, (value) {
                                setState(() {
                                  _lastName = value;
                                });
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Email dob phone no card
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        elevation: 2,
                        margin: const EdgeInsets.all(15.0),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Email
                              Text(
                                'Email',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              buildTextFormField(_email, (value) {
                                setState(() {
                                  _email = value;
                                });
                              }, readOnly: true),
                              const SizedBox(height: 10.0),

                              //Phone number
                              Text(
                                'Phone number',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              buildTextFormField(_phoneNumber, (value) {
                                setState(() {
                                  _phoneNumber = value;
                                });
                              }),
                              const SizedBox(height: 10.0),
                              //Date of birth
                              Text(
                                'Date of birth',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              buildTextFormField(_dateOfBirth, (value) {
                                setState(() {
                                  _dateOfBirth = value;
                                });
                              }),
                            ],
                          ),
                        ),
                      ),

                      //Save chnages button
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: MyButton(
                          buttonText: 'Save changes',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              updateUser();
                              Navigator.pop(context,
                                  true); // Return true to indicate successful update
                            }
                          },
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }

  TextFormField buildTextFormField(
      String initialValue, Function(String) onChanged,
      {bool readOnly = false}) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent, width: 0),
        ),
        filled: true,
      ),
      onChanged: onChanged,
    );
  }
}
