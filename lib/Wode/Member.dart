import 'package:flutter/material.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUCSA',

      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: Colors.white),
        useMaterial3: true,
      ),

    );
  }
}
