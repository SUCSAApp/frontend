import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




class NavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const NavBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  static const List<String> pageTitles = [
    'SUCSA',
    '活动',
    '商家',
    '校友会',
    '我的',
  ];

  @override
  _NavBarState createState() => _NavBarState();
}
class _NavBarState extends State<NavBar> {


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
          label: '商家',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.graduationCap),
          label: '校友会',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: const Color.fromRGBO(29, 32, 136, 1.0),
      unselectedItemColor: Colors.grey,
      onTap: widget.onItemSelected,
    );
  }

}
