import 'package:flutter/material.dart';
import 'Homepage/home_page.dart';
// import 'package:sucsa_app/Login.dart';
import 'api_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Color myColor = const Color.fromRGBO(29,32,136,1.0);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SUCSA',
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: Colors.white),
        useMaterial3: true,
      ),

      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController _staffUsernameController = TextEditingController();
  final TextEditingController _staffPasswordController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  void showLoginDialog(BuildContext context, bool isStaffLogin) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isStaffLogin ? 'STAFF Login' : 'Student Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: isStaffLogin ? _staffUsernameController : _studentIdController,
                  decoration: InputDecoration(
                    labelText: isStaffLogin ? 'Username' : 'Student ID',
                  ),
                ),
                TextFormField(
                  controller: isStaffLogin ? _staffPasswordController : _studentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
                // Add the confirm button here
                SizedBox(height: 20), // Spacing between input fields and the button
                ElevatedButton(
                  onPressed: () {
                    isStaffLogin ? _handleStaffLogin() : _handleStudentLogin();
                    Navigator.of(context).pop(); // Close the dialog after button press
                  },
                  child: Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    primary: myColor, // Button background color
                    onPrimary: Colors.white, // Button text color
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }



  void _handleStaffLogin() async {
    try {
      final result = await _apiService.staffLogin(
        _staffUsernameController.text,
        _staffPasswordController.text,
      );
      if (result['result'] != null && result['result']['token'] != null) {
        // Extract token, username, and roles
        String token = result['result']['token'];
        String username = result['result']['username'];
        List<dynamic> roles = result['result']['roles'];  // Assuming roles is a list

        // Use the token and other details as needed, e.g., navigate to a different home page based on role
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      } else {
        _showErrorDialog('Invalid staff credentials.');
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    }
  }


  void _handleStudentLogin() async {
    try {
      final result = await _apiService.studentLogin(
        _studentIdController.text,
        _studentPasswordController.text,
      );
      if (result['status'] == true && result['result'] != null) {
        // Extract token, username, and user type
        String token = result['result']['token'];
        String username = result['result']['username'];
        String userType = result['result']['user_type'];

        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
        );
      } else {
        _showErrorDialog('Invalid student credentials.');
      }
    } catch (e) {
      _showErrorDialog('Login failed. Please try again.');
    }
  }




  void _showErrorDialog(String message) {
    showDialog(
      context: navigatorKey.currentContext!, // Use navigatorKey.currentContext here
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    const double buttonWidth = 200.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            'lib/assets/login.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Wrap the ElevatedButton with a SizedBox to set a fixed width
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => showLoginDialog(context, false),
                  child: Text('普通登录'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: myColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0), // Adjust the padding
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => showLoginDialog(context, true),
                  child: Text('STAFF登录'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: myColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0), // Adjust the padding
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



