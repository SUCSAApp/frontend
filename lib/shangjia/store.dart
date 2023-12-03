import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;


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
    requestLocationPermission(); // Request permissions on init
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
    } else if (permission == LocationPermission.denied) {
      // Handle the case when the user denies permission.
      // Optionally, you can show a dialog or snackbar to inform the user.
    } else {
      // Permission is granted
      // You can fetch the current location or leave it until it's needed for distance calculation
      getCurrentLocation();
    }
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

  String? selectedTag;

  void _showFilterDialog() async {
    // Generate a list of tags from the restaurants. You might want to do this once and keep it in the state if it doesn't change often.
    final tags = restaurants.expand((restaurant) => restaurant.tags?.split(',') ?? []).toSet().toList();

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select a tag to filter by'),
        children: tags
            .map(
              (tag) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, tag),
            child: Text(tag),
          ),
        )
            .toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        selectedTag = selected;
        // Filter the restaurants list
        restaurants = restaurants.where((restaurant) {
          // If there are no tags or the selectedTag is null, include the restaurant in the list.
          if (restaurant.tags == null || selectedTag == null) {
            return true;
          }
          List<String> tagsList = restaurant.tags!.split(',');
          return tagsList.contains(selectedTag!);
        }).toList();
      });
    }
  }

  void clearFilter() {
    setState(() {
      selectedTag = null;
      fetchRestaurants(); // This assumes fetchRestaurants() will reset the restaurants list to unfiltered data.
    });
  }

  Widget buildFilterChip() {
    if (selectedTag != null) {
      return Container(
        padding: EdgeInsets.all(10),
        child: Chip(
          label: Text(selectedTag!),
          onDeleted: clearFilter,
        ),
      );
    } else {
      return Container(); // Return an empty container when there's no filter selected.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(isListView ? Icons.grid_view : Icons.list),
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
          : Column(
        children: [
          if (selectedTag != null) buildFilterChip(), // Only build the filter chip if there's a selected tag
          Expanded(
            child: isListView ? buildListView() : buildGridView(),
          ),
        ],
      ),
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
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = ListTile(
                title: Text(restaurant.title),
                subtitle: Text('Calculating distance...'),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.network(
                    restaurant.img,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              String errorMessage = 'Error: Could not calculate distance';
              if (snapshot.error is LocationServiceDisabledException) {
                errorMessage = 'Location services are disabled.';
              } else if (snapshot.error is PermissionDeniedException) {
                errorMessage = 'Location permission is denied.';
              }

              content = ListTile(
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
                    Text(restaurant.tags ?? 'No tags provided'),
                    SizedBox(height: 5),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                onTap: () => openDetailPage(restaurant),
              );
            } else {
              String distance = snapshot.data != null ? '${snapshot.data!.toStringAsFixed(2)} km' : 'Distance not available';
              content = ListTile(
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
                    ),
                    SizedBox(height: 5),
                    Text(
                      distance,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                onTap: () => openDetailPage(restaurant),
              );
            }

            return Card(
              margin: EdgeInsets.all(10),
              child: content,
            );
          },
        );
      },
    );
  }


  Widget buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns
        childAspectRatio: 1.0, // Aspect ratio of each grid cell
      ),
      itemCount: restaurants.length, // Total number of items
      itemBuilder: (context, index) {
        final restaurant = restaurants[index]; // Current restaurant item

        return Card(
          elevation: 4.0, // Shadow effect under the card
          margin: EdgeInsets.all(8.0), // Margin around each card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(restaurant: restaurant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the column to fill the card
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)), // Rounded corners at the top
                    child: Image.network(restaurant.img, fit: BoxFit.cover), // Restaurant image
                  ),
                ),
                ListTile(
                  title: Text(
                    restaurant.title,
                    style: const TextStyle(
                      fontFamily: 'Microsoft YaHei',
                    ),
                  ),
                ),
              ],
            ),
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
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(29, 32, 136, 1.0), // Use your preferred color
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Remove the SizedBox that was previously used to create space
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
                      SelectableText(
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
                        child: SelectableText(
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
                        child: SelectableText(
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
                    child: SelectableText('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(29, 32, 136, 1.0), // Button color
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
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, throw an error or handle it by showing a message to the user.
      return Future.error('Location permission denied by user.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, take the user to the app settings.
    openAppSettings();
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }

  // At this point, permissions are granted, so we can fetch the current location.
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

class LocationServiceDisabledException implements Exception {}

class PermissionDeniedException implements Exception {}

Future<double> _calculateDistance(Restaurant restaurant) async {
  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!isLocationServiceEnabled) {
    throw LocationServiceDisabledException();
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    throw PermissionDeniedException();
  }


  Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  double distanceInMeters = Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    restaurant.latitude ?? 0,
    restaurant.longitude ?? 0,
  );
  return distanceInMeters / 1000; // Convert to kilometers.
}


Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.deniedForever) {
    openAppSettings();
  } else if (permission == LocationPermission.denied) {
  }
}

void launchMap(String address) async {
  String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$address";
  String appleMapsUrl = "http://maps.apple.com/?q=$address";
  String mapUrl = Platform.isIOS ? appleMapsUrl : googleMapsUrl;

  if (await canLaunch(mapUrl)) {
    await launch(mapUrl);
  } else {
    throw 'Could not launch $mapUrl';
  }
}

