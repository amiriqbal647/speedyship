import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speedyship/components/my_button.dart';
import 'package:speedyship/pages/courier/become_courier.dart';
import 'package:speedyship/pages/courier/courier_main.dart';
import 'package:speedyship/pages/shipments/shipmentForm.dart';
import 'package:speedyship/pages/user/EditProfile.dart';
import 'package:speedyship/pages/user/ProfilePage.dart';
import 'package:speedyship/pages/user/orders.dart';
import 'CourierRequsets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:speedyship/components/our_service_card.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class UserMainPage extends StatefulWidget {
  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String _name = '';
  String _fname = '';
  String _lname = '';
  String _email = '';

  User? _user;

  @override
  void initState() {
    super.initState();
    _user = auth.currentUser;
    fetchUserData(_user!);

    //fetch the user data whenever the authentication state changes
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
                child: Text('aa'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.request_page),
              title: Text('Requests'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BidsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersPage(),
                  ),
                );
              },
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
            ListTile(
              leading: Icon(Icons.motorcycle),
              title: Text('Apply for Courier'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BecomeCourierPage(),
                  ),
                );
              },
            ),
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
      body: SingleChildScrollView(
        child: Center(
            child: Device.screenType == ScreenType.tablet
                ?
                //Desktop view***************************************************
                SizedBox(
                    width: 50.w,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // user name and welcome back tile
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                              trailing: CircleAvatar(
                                radius: 25,
                                child: Text('aa'),
                              ),
                              title: Text(
                                _name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              subtitle: Text('Welcome back!',
                                  style:
                                      Theme.of(context).textTheme.titleLarge)),

                          const SizedBox(
                            height: 15,
                          ),
                          // start shipping card
                          Card(
                            elevation: 5,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10.0,
                                ),
                                //box image
                                Image.asset(
                                  'lib/images/img1.png',
                                  height: 45.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),

                                // welcome text
                                Text(
                                  'Welcome to SpeedyShip',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),

                                // enjoy text
                                const Text('Enjoy our fast shipping service'),

                                // start shipping button
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  width: 160,
                                  child: MyButton(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShipmentInformation(),
                                          ),
                                        );
                                      },
                                      buttonText: 'Start shipping'),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Our Services
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                            child: Text(
                              'Our Services',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          //our services scroll
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                OurServiceCard(
                                  cardText: 'Hi there',
                                ),
                                OurServiceCard(
                                  cardText: 'Hi there',
                                ),
                                OurServiceCard(
                                  cardText: 'Hi there',
                                ),
                                OurServiceCard(
                                  cardText: 'Hi there',
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                :
                //Mobile view*************************************************************
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // user name and welcome back tile
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                            trailing: CircleAvatar(
                              radius: 25,
                              child: Text('aa'),
                            ),
                            title: Text(
                              _name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text('Welcome back!',
                                style: Theme.of(context).textTheme.titleLarge)),

                        const SizedBox(
                          height: 15,
                        ),
                        // start shipping card
                        Card(
                          elevation: 5,
                          child: Column(
                            children: [
                              //box image
                              Image.asset(
                                'lib/images/img1.png',
                                height: 25.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),

                              // welcome text
                              Text(
                                'Welcome to SpeedyShip',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),

                              // enjoy text
                              const Text('Enjoy our fast shipping service'),

                              // start shipping button
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                width: 160,
                                child: MyButton(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ShipmentInformation(),
                                        ),
                                      );
                                    },
                                    buttonText: 'Start shipping'),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Our Services
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                          child: Text(
                            'Our Services',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        //our services scroll
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              OurServiceCard(
                                cardText: 'Hi there',
                              ),
                              OurServiceCard(
                                cardText: 'Hi there',
                              ),
                              OurServiceCard(
                                cardText: 'Hi there',
                              ),
                              OurServiceCard(
                                cardText: 'Hi there',
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
      ),
    );
  }
}
