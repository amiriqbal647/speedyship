import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/pages/courier/CourierProfile.dart';
import 'package:speedyship/pages/courier/courierRatings.dart';
import 'package:speedyship/pages/courier/deliveries.dart';
import 'AcceptedBidsPage.dart';
import 'IndvidualUserSh.dart';
import 'RejectedBidsPage.dart';
import 'editCourierAccount.dart';
import 'package:speedyship/pages/courier/courier_help_page.dart';

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
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_name),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                //need to be fixed
                child: Text(
                  _name.isNotEmpty ? '${_fname[0]}${_lname[0]}' : '',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Account'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourierProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all_rounded),
              title: const Text('accepted Requests'),
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
              leading: const Icon(Icons.block_flipped),
              title: const Text('Rejected Requests'),
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
              leading: const Icon(Icons.local_shipping),
              title: const Text('Deliveries'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveriesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text('Ratings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourierRatingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourierHelpPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
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
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _selectedCity == cityNames[index]
                          ? Theme.of(context)
                              .colorScheme
                              .primary // Selected city color
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

                            return GestureDetector(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //List tile
                                      ListTile(
                                        leading: CircleAvatar(
                                          child: Text(username[0]),
                                        ),
                                        title: Text(username),
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),

                                      //Location and destination
                                      Text(
                                        'Location & Destination',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),

                                      //City
                                      ListTile(
                                        leading:
                                            const Icon(Icons.location_city),
                                        title: Text(city),
                                      ),

                                      //Location
                                      ListTile(
                                        leading: const Icon(Icons.location_pin),
                                        title: Text('$location'),
                                      ),
                                      //destination
                                      ListTile(
                                        leading: const Icon(Icons.location_on),
                                        title: Text('$destination'),
                                      ),

                                      const SizedBox(
                                        height: 10.0,
                                      ),
                                      const Divider(),

                                      //Shipment details
                                      Text(
                                        'Shipment Details',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(
                                        height: 10.0,
                                      ),

                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //Category
                                          Column(
                                            children: [
                                              const Icon(Icons.category),
                                              Text(
                                                '$category',
                                              ),
                                            ],
                                          ),

                                          //Weight
                                          Column(
                                            children: [
                                              const Icon(Icons.line_weight),
                                              Text(
                                                '$weight KG',
                                              ),
                                            ],
                                          ),

                                          //Width
                                          Column(
                                            children: [
                                              const Icon(Icons.width_full),
                                              Text(
                                                '$width CM',
                                              ),
                                            ],
                                          ),

                                          //Height
                                          Column(
                                            children: [
                                              const Icon(Icons.height),
                                              Text(
                                                '$height CM',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
