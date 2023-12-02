import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Restaurant model class
class Restaurant {
  final int id;
  final String date;
  final String? description;
  final String title;
  final String img;
  final String? tags;
  final String? discount;
  final String? phone;
  final String address;
  final String? wechat;
  final String country;
  final bool top;
  final double? latitude;
  final double? longitude;

  Restaurant({
    required this.id,
    required this.date,
    this.description,
    required this.title,
    required this.img,
    this.tags,
    this.discount,
    this.phone,
    required this.address,
    this.wechat,
    required this.country,
    required this.top,
    this.latitude,
    this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      date: json['date'] ?? 'Unknown date',
      description: json['description'],
      title: json['title'] ?? 'Untitled',
      img: json['img'] ?? '',
      tags: json['tags'],
      discount: json['discount'],
      phone: json['phone'],
      address: json['address'] ?? '',
      wechat: json['wechat'],
      country: json['country'] ?? 'Unknown',
      top: json['top'] ?? false,
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Restaurant> restaurants = [];
  bool isLoading = true;
  bool isListView = false;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    try {
      var response = await http.post(
        Uri.parse('https://sucsa.org:8004/api/public/restaurants'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        String decodedBody = utf8.decode(response.bodyBytes);
        List<dynamic> data = json.decode(decodedBody)['data'];
        // List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          restaurants = data.map((item) => Restaurant.fromJson(item)).toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(isListView ? Icons.grid_view : Icons.list), // Change the icon based on the view type
            onPressed: () {
              setState(() {
                isListView = !isListView; // Toggle the view type
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isListView ? buildListView() : buildGridView(), // Use a ternary operator to switch views
    );
  }
  Widget buildListView() {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];

        return FutureBuilder<double>(
          future: _calculateDistance(restaurant),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text('Calculating distance...'),
              );
            }

            if (snapshot.hasError) {
              return ListTile(
                title: Text('Error: ${snapshot.error}'),
              );
            }

            String distance = snapshot.data != null ? '${snapshot.data!.toStringAsFixed(2)} km' : 'Distance not available';

            return Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    restaurant.img,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(restaurant.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.tags ?? 'No tags provided',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          distance,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () => openDetailPage(restaurant),
              ),
            );
          },
        );
      },
    );
  }


  Widget buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
      ),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(restaurant: restaurant),
            ),
          ),
          child: GridTile(
            footer: GridTileBar(
              backgroundColor: Colors.black45,
              title: Text(
                restaurant.title,
                style: const TextStyle(
                  fontFamily: 'Microsoft YaHei',
                ),
              ),
            ),
            child: Image.network(restaurant.img, fit: BoxFit.cover),
          ),
        );
      },

    );
  }



  void openDetailPage(Restaurant restaurant) {
    // Navigate to the detail page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailPage(restaurant: restaurant),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Restaurant restaurant;

  DetailPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  restaurant.img,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue), // Phone icon
                      SizedBox(width: 10),
                      Text(
                        restaurant.phone ?? 'No phone provided',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.local_offer, color: Colors.purple), // Discount icon
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          restaurant.discount ?? 'No discount provided',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.wechat, color: Colors.green), // WeChat icon
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          restaurant.wechat ?? 'No WeChat provided',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red), // Location icon
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(restaurant.address),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => launchMap(restaurant.address),
                    child: Text('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue, // Button color
                      onPrimary: Colors.white, // Text color
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Position> getCurrentLocation() async {
  PermissionStatus locationPermissionStatus = await Permission.location.status;
  if (locationPermissionStatus != PermissionStatus.granted) {
    await requestLocationPermission();
  }
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<double> _calculateDistance(Restaurant restaurant) async {
  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationServiceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  double distanceInMeters = Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    restaurant.latitude ?? 0,
    restaurant.longitude ?? 0,
  );
  return distanceInMeters / 1000;
}

Future<void> requestLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isGranted) {
    // Permission granted, you can now use location services.
  } else {
    // Permission denied.
    if (status.isDenied) {
      // The user denied the permission once, you can explain why you need it and request again.
    } else if (status.isPermanentlyDenied) {
      // The user permanently denied the permission. You can open app settings to allow the user to enable it manually.
      openAppSettings();
    }
  }
}


void launchMap(String address) async {
  final url = Uri.encodeFull('https://www.google.com/maps/search/?api=1&query=$address');
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
