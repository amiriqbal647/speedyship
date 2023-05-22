import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AcceptedBidsPage.dart';
import 'IndvidualUserSh.dart';
import 'RejectedBidsPage.dart';
import 'editCourierAccount.dart';

class CourierMain extends StatefulWidget {
  @override
  _CourierMainState createState() => _CourierMainState();
}

class _CourierMainState extends State<CourierMain> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _name = '';
  String _fname = '';
  String _lname = '';
  String _email = '';

  User? _user;

  String _selectedCity = 'All';
  List<String> cityNames = [
    'All',
    'Famagusta',
    'Nicosia',
    'Karpas',
    'Kerniya',
    'Lefke',
    'Morphou'
  ]; // Replace with your desired city names

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser;
    fetchUserData(_user!);

    // Fetch the user data whenever the authentication state changes
    auth.authStateChanges().listen((user) {
      if (user != null) {
        _user = user;
        fetchUserData(user);
      }
    });
  }

  Future<void> fetchUserData(User user) async {
    final userData = await firestore.collection('users').doc(user.uid).get();
    setState(() {
      _fname = userData.get('firstName');
      _lname = userData.get('lastName');
      _name = ('$_fname $_lname');
      _email = userData.get('email');
    });
  }

  void filterShipments(String city) {
    setState(() {
      _selectedCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              accountName: Text(_name),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                child: Text('MA'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.done_all_rounded),
              title: Text('accepted Requests'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcceptedBidsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.block_flipped),
              title: Text('Rejected Requests'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RejectedBidsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Orders'),
              /*onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyOrders(),
                  ),
                );
              },*/
            ),
            ListTile(
              leading: Icon(Icons.star_rate),
              title: Text('Ratings'),
              /*onTap: () {
                // Add the desired functionality for Ratings here
              },*/
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              /*onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelpPage(),
                  ),
                );
              },*/
            ),
            Divider(),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              itemCount: cityNames.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => filterShipments(cityNames[index]),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _selectedCity == cityNames[index]
                          ? Color.fromRGBO(
                              9, 147, 120, 1) // Selected city color
                          : Colors.grey[300], // Unselected city color
                    ),
                    child: Center(
                      child: Text(
                        cityNames[index],
                        style: TextStyle(
                          color: _selectedCity == cityNames[index]
                              ? Colors.white // Selected city text color
                              : Colors.black, // Unselected city text color
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('shipments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final shipments = snapshot.data!.docs;

                  List<DocumentSnapshot> filteredShipments = shipments;
                  if (_selectedCity != 'All') {
                    filteredShipments = shipments
                        .where((shipment) =>
                            shipment.get('city').toLowerCase() ==
                            _selectedCity.toLowerCase())
                        .toList();
                  }

                  return ListView.builder(
                    itemCount: filteredShipments.length,
                    itemBuilder: (context, index) {
                      final shipment = filteredShipments[index];

                      // Retrieve the shipment data
                      final city = shipment.get('city');
                      final location = shipment.get('location');
                      final destination = shipment.get('destination');
                      final category = shipment.get('category');
                      final height = shipment.get('height');
                      final weight = shipment.get('weight');
                      final width = shipment.get('width');
                      final length = shipment.get('length');

                      // Retrieve the username based on userId
                      final userId = shipment.get('userId');

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            final username =
                                userSnapshot.data!.get('firstName');

                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(15.0),
                                title: Text(
                                  username,
                                  style: TextStyle(
                                    color: Color.fromRGBO(9, 147, 120, 1),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .white, // Updated the background color
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          city,
                                          style: TextStyle(
                                            color: Color.fromRGBO(231, 123, 0,
                                                1), // Updated the text color
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Location: $location',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 106, 106, 106),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Destination: $destination',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 106, 106, 106),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Category: $category',
                                      style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 106, 106, 106),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Height: $height',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Weight: $weight',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Width: $width',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Length: $length',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          IndividualUserShipment(
                                        city: city,
                                        location: location,
                                        destination: destination,
                                        category: category,
                                        height: height,
                                        weight: weight,
                                        width: width,
                                        length: length,
                                        username: username,
                                        userId: userId,
                                        shipmentId: shipment.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          if (userSnapshot.hasError) {
                            return ListTile(
                              title: Text(
                                'Error retrieving username',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              'Loading username...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error retrieving shipments',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(9, 147, 120, 1),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
