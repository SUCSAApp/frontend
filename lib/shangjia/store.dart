import 'package:flutter/material.dart';

class storepage extends StatefulWidget {
  const storepage({super.key});

  @override
  State<storepage> createState() => _storepageState();
}

class _storepageState extends State<storepage> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '商家',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
