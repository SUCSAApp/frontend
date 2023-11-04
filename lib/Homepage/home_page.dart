import 'package:flutter/material.dart';
import 'package:sucsa_app/Alumini/alumimi.dart';
import '../activity/activity_page.dart';
import '../shangjia/store.dart';
import '../Mysucsa/my_sucsa_page.dart';
// Assuming the NavBar is in the same directory
 import 'package:sucsa_app/Components/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
// sdfs

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
                child: Image.asset('lib/assets/mainpage.PNG',height: 200,),
              ),
              const Column(
                children: [
                  Text(
                    '悉尼大学中国学联',
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  Text(
                    'Sydney University Chinese Students &',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  Text(
                    'Scholars Association',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    )
                ],
              )
              
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('lib/assets/官方组织.png', height: 100,),
              Image.asset('lib/assets/第三方合作.png', height: 100,),]),
        ),

        const Padding(
          padding: EdgeInsets.only(top: 10.0, left: 20.0),
          child: Text('最新动态', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        ),

        Container(
              margin: const EdgeInsets.all(10.0),
              child: Card(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      child: Image.asset('lib/assets/图书馆.png', height: 150, fit: BoxFit.fill,),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Expanded(
                          child: ListTile(
                            title: Text('推文1'),
                            subtitle: Text('万圣节'),
                          )
                        ),
                        Image.asset('lib/assets/查看详情.png', height: 40,),
                      ],
                    ),
                    
                  ],
                ),
              ),
            )
        

        // You can add more widgets here to be part of the scrollable content
        //   add a widget to place some tex
      ],
    ),
    const ActivityPage(),
    const storepage(),
    const aluminiPage(),
    const MySUCSAPage(),
  ];

  void _onNavBarItemTapped(int index) {
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
          NavBar.pageTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }
}
