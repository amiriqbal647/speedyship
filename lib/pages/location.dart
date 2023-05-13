import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocation extends StatefulWidget {
  @override
  _SelectLocationState createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(39.1667, 35.6667); // Cyprus LatLng
  String? _selectedAddress;
  LatLng? _selectedLatLng;
  final _searchController = TextEditingController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _selectedAddress =
          "${place.thoroughfare},${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      _selectedLatLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _selectedAddress != null
                ? () {
                    Navigator.pop(context, _selectedAddress);
                  }
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    List<Location> locations =
                        await locationFromAddress(_searchController.text);
                    mapController.animateCamera(CameraUpdate.newLatLng(
                        LatLng(locations[0].latitude, locations[0].longitude)));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: _onMapTapped,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _selectedLatLng != null
                  ? {
                      Marker(
                        markerId: MarkerId(_selectedLatLng.toString()),
                        position: _selectedLatLng!,
                      ),
                    }
                  : {},
            ),
          ),
        ],
      ),
    );
  }
}
