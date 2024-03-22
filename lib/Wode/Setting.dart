import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../main.dart';
import 'Abouts/PrivacyPolicy.dart';
import 'Abouts/TermsofUse.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('系统设置'),
                  leading: Icon(Icons.settings),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SystemSettingsPage(),
                    ));
                  },
                ),
                ListTile(
                  title: Text('账户设置'),
                  leading: Icon(Icons.account_circle),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AccountSettingsPage(),
                    ));
                  },
                ),
                ListTile(
                  title: Text('关于'),
                  leading: Icon(Icons.info_outline),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ));
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color.fromRGBO(29,32,136,1.0),
                      ),
                      child: Text('Log Out'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Copyright © 2023 SUCSA - 悉尼大学中国学联\n                   All Rights Reserved",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('staffUsername');
    await prefs.remove('studentId');
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关于'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Privacy Policy'),
            onTap: () {
              // Navigate to Privacy Policy Page
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PrivacyPolicy(),
              ));
            },
          ),
          ListTile(
            title: Text('Terms of Use'),
            onTap: () {
              // Navigate to Terms of Use Page
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TermsofUse(),
              ));
            },
          ),
          ListTile(
            title: Text('Copyright Certificate'),
            onTap: () => _openPDF(context),
          ),

        ],

      ),
    );
  }

  void _openPDF(BuildContext context) async {
    final path = 'lib/assets/Copyright.pdf';
    final file = await _loadPDFAsset(path);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PDFViewerPage(path: file.path),
    ));
  }

  Future<File> _loadPDFAsset(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp.pdf');
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }
}

class PDFViewerPage extends StatelessWidget {
  final String path;
  PDFViewerPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}


class SystemSettingsPage extends StatefulWidget {
  @override
  _SystemSettingsPageState createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  String _language = '简体中文';
  ThemeMode _themeMode = ThemeMode.system;
  double _textSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('系统设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Language'),
            subtitle: Text(_language),
            onTap: () => _showLanguagePicker(context),
          ),
          ListTile(
            title: Text('Theme'),
            subtitle: Text(_themeModeToString(_themeMode)),
            onTap: () => _showThemePicker(context),
          ),
          ListTile(
            title: Text('Text Size'),
            subtitle: Text('Current size: ${_textSize.toStringAsFixed(0)}'),
            onTap: () => _showTextSizeAdjuster(context),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Language"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('English'),
                  onTap: () {
                    _setLanguage('English');
                    Navigator.of(context).pop();
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('简体中文'),
                  onTap: () {
                    _setLanguage('简体中文');
                    Navigator.of(context).pop();
                  },
                ),
                GestureDetector(
                  child: Text('繁体中文'),
                  onTap: () {
                    _setLanguage('繁体中文');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: new Icon(Icons.light_mode),
                    title: new Text('Normal'),
                    onTap: () => _setThemeMode(ThemeMode.light)),
                ListTile(
                  leading: new Icon(Icons.dark_mode),
                  title: new Text('Dark'),
                  onTap: () => _setThemeMode(ThemeMode.dark),
                ),
                ListTile(
                  leading: new Icon(Icons.brightness_auto),
                  title: new Text('Follow System'),
                  onTap: () => _setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          );
        });
  }

  void _showTextSizeAdjuster(BuildContext context) {
    // Example dialog for text size adjustment
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adjust Text Size"),
          content: SingleChildScrollView(
            child: Slider(
              min: 12.0,
              max: 24.0,
              divisions: 12,
              value: _textSize,
              label: _textSize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _textSize = value;
                });
                Navigator.of(context).pop();
                _setTextSize(value);
              },
            ),
          ),
        );
      },
    );
  }

  void _setLanguage(String language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _language = language;
    });
    await prefs.setString('language', language);
    // You might need to trigger a rebuild or notify listeners to update UI based on the new language
  }

  void _setThemeMode(ThemeMode themeMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = themeMode;
    });
    await prefs.setString('themeMode', themeMode.toString());

  }

  void _setTextSize(double textSize) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textSize', textSize);
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Normal';
      case ThemeMode.system:
        return 'Follow System';
      default:
        return 'Unknown';
    }
  }
}


class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Unknown';
      _email = prefs.getString('email') ?? 'No email set';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('账户设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('用户名'),
            subtitle: Text(_username),
            leading: Icon(Icons.person),
          ),
          ListTile(
            title: Text('电子邮件'),
            subtitle: Text(_email),
            leading: Icon(Icons.email),
          ),
          // Add more user information fields here as needed
        ],
      ),
    );
  }
}
