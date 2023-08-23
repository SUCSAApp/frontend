import 'package:flutter/material.dart';
import '../activity/activity_page.dart';
import '../shangjia/offer_page.dart';
import '../Mysucsa/my_sucsa_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset('assets/mainpage.PNG'),
              ),
              const Text(
                '悉尼大学中国学联',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),

        // You can add more widgets here to be part of the scrollable content
      //   add a widget to place some text
        const Padding(padding: EdgeInsets.only(top:10.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Text(
                '我们是谁？',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
        ),

      ],
    ),
    const ActivityPage(),
    const OfferPage(),
    const MySUCSAPage(),
  ];

  final List<String> _pageTitles = [
    'SUCSA',
    '活动',
    '优惠',
    '我的',
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: '活动',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '优惠',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(29, 32, 136, 1.0),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
