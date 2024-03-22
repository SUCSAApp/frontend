import 'package:flutter/material.dart';
import 'Homepage/home_page.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _staffUsernameController = TextEditingController();
  final TextEditingController _staffPasswordController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _showSplash = true;
  bool _showLoginButtons = false;

  bool _isRememberMeStaff = false;
  bool _isRememberMeStudent = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _showSplash = false;
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _showLoginButtons = true;
        });
      });
    });
  }

  void _loadCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? staffLoginTimestamp = prefs.getInt('staffLoginTimestamp');
    int? studentLoginTimestamp = prefs.getInt('studentLoginTimestamp');

    if (staffLoginTimestamp != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - staffLoginTimestamp > 30 * 24 * 60 * 60 * 1000) {
        await prefs.remove('staffUsername');
        await prefs.remove('staffLoginTimestamp');
      }
      else {
        _staffUsernameController.text = prefs.getString('staffUsername') ?? '';
      }
    }

    if (studentLoginTimestamp != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - studentLoginTimestamp > 30 * 24 * 60 * 60 * 1000) {
        await prefs.remove('studentId');
        await prefs.remove('studentLoginTimestamp');

      } else {
        _studentIdController.text = prefs.getString('studentId') ?? '';
      }
    }
  }

  void _setExpenseManagers() async {
    final List<int> userIds = [149, 147];

    for (int userId in userIds) {
      final url = 'http://cms.sucsa.org:8005/api/user/$userId/set-expense-manager';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          print('User $userId set as expense manager successfully.');
        } else {
          print('Failed to set user $userId as expense manager. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error setting user $userId as expense manager: $e');
      }
    }
  }

  void _setWareHouseManagers() async {
    final List<int> userIds = [51, 15];

    for (int userId in userIds) {
      final url = 'http://cms.sucsa.org:8005/api/user/$userId/set-warehouse-manager'
      ;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({"userId": userId}),
        );

        if (response.statusCode == 200) {
          print('User $userId set as warehouse manager successfully.');
        } else {
          print('Failed to set user $userId as warehouse manager. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error setting user $userId as warehouse manager: $e');
      }
    }
  }

  void _saveCredentials(bool isStaffLogin, String token, String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userType', userType);
    if (isStaffLogin && _isRememberMeStaff) {
      await prefs.setString('staffUsername', _staffUsernameController.text);
      await prefs.setInt('staffLoginTimestamp', DateTime.now().millisecondsSinceEpoch);
    } else if (!isStaffLogin && _isRememberMeStudent) {
      await prefs.setString('studentId', _studentIdController.text);
      await prefs.setInt('studentLoginTimestamp', DateTime.now().millisecondsSinceEpoch);
    }
  }

  void showLoginDialog(BuildContext context, bool isStaffLogin) {
    showDialog(
      context: context,
      builder: (context) {
        bool localIsRememberMe = isStaffLogin ? _isRememberMeStaff : _isRememberMeStudent;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(isStaffLogin ? 'STAFF Login' : 'Student Login'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: isStaffLogin
                          ? _staffUsernameController
                          : _studentIdController,
                      decoration: InputDecoration(
                        labelText: isStaffLogin ? 'Username' : 'Student ID',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black, width: 2.0),
                        ),
                        floatingLabelStyle: TextStyle(color: Colors.black),
                      ),
                      cursorColor: Colors.blueAccent,
                      cursorWidth: 2.0,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: isStaffLogin
                          ? _staffPasswordController
                          : _studentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black, width: 2.0),
                        ),
                      ),
                      obscureText: true,
                      cursorColor: Colors.black,
                      cursorWidth: 2.0,
                    ),
                CheckboxListTile(
                  title: Text('Stay Sign in for 30 days', style: TextStyle(fontSize: 11),),
                  value: localIsRememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      localIsRememberMe = value!;
                      if (isStaffLogin) {
                        _isRememberMeStaff = value;
                      } else {
                        _isRememberMeStudent = value;
                      }
                      _saveCredentials(isStaffLogin, '', '');
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: myColor,
                ),
                  SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        isStaffLogin
                            ? _handleStaffLogin()
                            : _handleStudentLogin();
                        Navigator.of(context).pop();
                      },
                      child: Text('登录',style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: myColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
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
        String token = result['result']['token'];
        String username = result['result']['username'];
        List<dynamic> roles = result['result']['roles'];
        _saveCredentials(true, token, 'staff');


        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', username);
        await prefs.setString('roles', jsonEncode(roles));
        await _apiService.saveToken(token, token);

        _setWareHouseManagers();
        _setExpenseManagers();
        print('username: $username');
        print('Roles: $roles');
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
        String token = result['result']['token'];
        String username = result['result']['username'];
        String userType = result['result']['user_type'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userType', userType);
        _saveCredentials(false, token, 'student');

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
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
            'lib/assets/login.jpg',
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          AnimatedOpacity(
            opacity: _showSplash ? 1.0 : 0.0,
            duration: Duration(seconds: 1),
            child: Container(
              alignment: Alignment.center,
              child: Image.asset('lib/assets/mascot.jpg',
              fit: BoxFit.fill,)
            ),
          ),
        if (!_showSplash) ...[
        AnimatedOpacity(
            opacity: _showLoginButtons ? 1.0 : 0.0,
            duration: Duration(seconds: 2),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  onPressed: () => showLoginDialog(context, false),
                  child: Text('普通登录', style: TextStyle(fontWeight: FontWeight.bold),),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: myColor, backgroundColor: Colors.white,
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
                  child: Text('STAFF登录',style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: myColor, backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                  ),
                ),
              )],
            ),
        ),
        ],
        ]),
    );
  }
}



