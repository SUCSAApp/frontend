import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'description': description,
      'title': title,
      'img': img,
      'tags': tags,
      'discount': discount,
      'phone': phone,
      'address': address,
      'wechat': wechat,
      'country': country,
      'top': top,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class RestaurantEvent {
  final int id;
  final String date;
  final String link;
  final String title;
  final String img;
  final int orderNumber;

  RestaurantEvent({
    required this.id,
    required this.date,
    required this.link,
    required this.title,
    required this.img,
    required this.orderNumber,
  });

  factory RestaurantEvent.fromJson(Map<String, dynamic> json) {
    return RestaurantEvent(
      id: json['id'],
      date: json['date'],
      link: json['link'],
      title: json['title'],
      img: json['img'],
      orderNumber: json['orderNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'link': link,
      'title': title,
      'img': img,
      'orderNumber': orderNumber,
    };
  }
}

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Restaurant> restaurants = [];
  List<Restaurant> allRestaurants = [];
  List<RestaurantEvent> restaurantEvents = [];
  bool isLoading = true;
  bool isListView = false;
  Position? _currentUserPosition;


  @override
  void initState() {
    super.initState();

    requestLocationPermission();
    loadDataFromCache().then((_) {
      if (restaurants.isEmpty || restaurantEvents.isEmpty) {
        fetchRestaurants();
        fetchRestaurantEvents();
      }
    });
  }

  Future<void> loadDataFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? restaurantsJson = prefs.getStringList('restaurants');
    List<String>? restaurantEventsJson = prefs.getStringList('restaurantEvents');

    if (restaurantsJson != null) {
      restaurants = restaurantsJson.map((json) => Restaurant.fromJson(jsonDecode(json))).toList();
    }

    if (restaurantEventsJson != null) {
      restaurantEvents = restaurantEventsJson.map((json) => RestaurantEvent.fromJson(jsonDecode(json))).toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchRestaurantEvents() async {
    final response = await http.post(
      Uri.parse('https://sucsa.org:8004/api/public/restaurantEvents'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        restaurantEvents = data.map((json) => RestaurantEvent.fromJson(json)).toList();
        cacheData();
      });
    } else {
      print('Failed to fetch events');
    }
  }

  bool isRequestingLocationPermission = false;

  Future<void> requestLocationPermission() async {
    if (isRequestingLocationPermission) {
      return; // If a request is already in progress, do not proceed.
    }

    isRequestingLocationPermission = true; // Set the flag to indicate that a request is in progress.

    try {
      print('Requesting location permission...');
      LocationPermission permission = await Geolocator.requestPermission();
      print('Permission status: $permission');
      if (permission == LocationPermission.deniedForever) {
        print('Permission denied forever, opening app settings...');
        await openAppSettings();
      } else if (permission == LocationPermission.denied) {
        print('Permission denied by user.');
        // Handle the case where the user denies the permission.
      } else {
        // Permission granted, we can now call the method to get the current location.
        print('Permission granted, getting current location...');
        await getCurrentLocation();
      }
    } on Exception catch (e) {
      print('An exception occurred: $e');
      throw Exception('Failed to load restaurants'); // Consider providing a more specific error message
    } finally {
      isRequestingLocationPermission = false; // Reset the flag when done.
    }
  }

  Future<void> cacheData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> restaurantsJson = restaurants.map((restaurant) => jsonEncode(restaurant.toJson())).toList();
    List<String> restaurantEventsJson = restaurantEvents.map((event) => jsonEncode(event.toJson())).toList();
    await prefs.setStringList('restaurants', restaurantsJson);
    await prefs.setStringList('restaurantEvents', restaurantEventsJson);
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
        List<Restaurant> fetchedRestaurants = data.map((json) => Restaurant.fromJson(json)).toList();

        setState(() {
          allRestaurants = fetchedRestaurants;
          restaurants = fetchedRestaurants;
          isLoading = false;
          cacheData();
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading restaurants: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String? selectedTag;

  void _showFilterDialog() async {

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
        restaurants = restaurants.where((restaurant) {
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
      restaurants = List.from(allRestaurants);
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
      return Container();
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
                isListView = !isListView;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: <Widget>[
          if (restaurantEvents.isNotEmpty)
            SliverToBoxAdapter(
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                ),
                items: restaurantEvents.map((event) => Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GestureDetector(
                          onTap: () {
                            _launchURL(event.link);
                          },
                          child: Image.network(
                            event.img,
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                        ),
                      ),
                    );
                  },
                )).toList(),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.all(8.0),
            sliver: isListView ? buildSliverList() : buildSliverGrid(),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildSliverList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
    (BuildContext context, int index) {
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
          childCount: restaurants.length,
        )
    );
  }

  Widget buildSliverGrid() {
    return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
    ),
    delegate: SliverChildBuilderDelegate(
    (BuildContext context, int index) {
    final restaurant = restaurants[index];
        return Card(
          elevation: 4.0,
          margin: EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(restaurant: restaurant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                    child: Image.network(restaurant.img, fit: BoxFit.cover),
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
    childCount: restaurants.length,
    )
    );
  }

  void openDetailPage(Restaurant restaurant) {
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
          title: Text(restaurant.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
        ),
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
                          onPressed: () => _openWithDialog(context, restaurant.address),
                          child: Text('Open with'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29, 32, 136, 1.0), // Text color
                          ),

                        ),
                      ],
                    ),
                  ),
                ])
        )
    );
  }


  void _openWithDialog(BuildContext context, String address) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: new Icon(FontAwesomeIcons.google),
                title: new Text('Google Maps'),
                onTap: () => _launchMapsUrl(context, address, 'google'),
              ),
              ListTile(
                leading: new Icon(FontAwesomeIcons.apple),
                title: new Text('Apple Maps'),
                onTap: () => _launchMapsUrl(context, address, 'apple'),
              ),
              if (Platform.isAndroid)
                ListTile(
                  leading: new Icon(FontAwesomeIcons.android),
                  title: new Text('Native Map'),
                  onTap: () => _launchMapsUrl(context, address, 'native'),
                ),
            ],
          ),
        );
      },
    );
  }


  void _launchMapsUrl(BuildContext context, String address, String mapType) async {
    String url;
    if (mapType == 'google') {
      url = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";
    } else if (mapType == 'apple') {
      url = "http://maps.apple.com/?q=${Uri.encodeComponent(address)}";
    } else { // 'native' for Android
      url = "geo:0,0?q=${Uri.encodeComponent(address)}";
    }

    Navigator.pop(context); // Close the dialog

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch map')),
      );
    }
  }
}


Future<Position> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied by user.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    openAppSettings();
    return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  }
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


  Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  double distanceInMeters = Geolocator.distanceBetween(
    currentPosition.latitude,
    currentPosition.longitude,
    restaurant.latitude ?? 0,
    restaurant.longitude ?? 0,
  );
  return distanceInMeters / 1000;
}








