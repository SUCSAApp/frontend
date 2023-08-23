import 'package:flutter/material.dart';
import 'Homepage/home_page.dart';

void main() {
  runApp(const MyApp());
}
Color myColor = const Color.fromRGBO(29,32,136,1.0);
// this is the main page of the app
class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUCSA',

      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: Colors.white),
        useMaterial3: true,
      ),

      home: const HomePage(),
    );
  }
}
