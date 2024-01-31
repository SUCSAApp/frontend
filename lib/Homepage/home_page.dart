import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sucsa_app/Alumini/alumni.dart';
import '../activity/activity_page.dart';
import '../shangjia/store.dart';
import '../Mysucsa/my_sucsa_page.dart';
// Assuming the NavBar is in the same directory
import 'package:sucsa_app/Components/navbar.dart';

import 'package:sucsa_app/Staticpg1/home_static_pg.dart';
import 'package:sucsa_app/Staticpg2/home_static_pg2.dart';
import 'package:sucsa_app/Staticpg3/home_static_pg3.dart';



import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ActivityPage(),
    const StorePage(),
    const AlumniPage(),
    const MySUCSAPage(),
  ];

  Widget topBanner(){
    return Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset('lib/assets/mainpage.PNG', height: 200,),
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
        );
  }

  Widget threeButtons(){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          buttonWithBackground(Icon(Icons.language), '合作官方组织', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeStaticPage1()));
          }),
          buttonWithBackground(Icon(Icons.group), '第三方合作', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
          }),
          buttonWithBackground(Icon(Icons.tv), '学联媒体平台', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeStaticPage3()));
          }),
        ],
      ),
    );
  }

  Widget buttonWithBackground(Icon icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[0],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon.icon,
              size: 50,
              color: Color.fromRGBO(29,32,136,1.0),
            ),
            Container(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textTitle(){  //最新动态
    return const Padding(
          padding: EdgeInsets.only(top: 5.0, left: 20.0),
          child: Text('最新动态', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        );
  }

  Widget bottomView1(String title, String subtitle, String img){ //左图片，右文字
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 1.0),
                ),
        ],
      ),
      child: Card(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Image.network(img, height: 150, fit: BoxFit.fill,),
            ),
            Expanded(
              flex: 7,
              child: Stack(
                children: <Widget>[
                  const SizedBox(
                    height: 150,
                  ),

                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(title),
                        titleAlignment: ListTileTitleAlignment.top,
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        subtitle: Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis,),
                        subtitleTextStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      )
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 5,
                    child: IconButton(onPressed: () {}, icon: Image.asset('lib/assets/查看详情.png', height: 25, fit: BoxFit.fill,)),
                    )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget bottomView2(String title, String subtitle, String img){  //右图片，左文字
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 1.0),
                ),
        ],
      ),
      child: Card(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Stack(
                children: <Widget>[
                  const SizedBox(
                    height: 150,
                  ),

                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ListTile(
                        title: Text(title),
                        titleAlignment: ListTileTitleAlignment.top,
                        titleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        subtitle: Text(subtitle, maxLines: 3, overflow: TextOverflow.ellipsis,),
                        subtitleTextStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      )
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 5,
                    child: IconButton(onPressed: () {}, icon: Image.asset('lib/assets/查看详情.png', height: 25, fit: BoxFit.fill,)),
                    )

                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Image.network(img, height: 150, fit: BoxFit.fill,),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<List<String>>> getRequest() async {  //POST REQUEST
    String url = 'https://sucsa.org:8004/api/public/activities';
    final res = await http.post(Uri.parse(url), body: 'Test');

    Map<String, dynamic> message = json.decode(utf8.decode(res.bodyBytes));

    List<dynamic> data = message['data'];

    List<List<String>> bottomList = [];  //存储所有推文
    data.forEach((element) {
      List<String> ls = [];
      (element as Map<String, dynamic>).forEach((key, value) {
        if(key == 'title'){
          ls.add(value);
        }
        else if(key == 'description'){
          ls.add(value);
        }
        else if(key == 'img'){
          ls.add(value);
        }
      });
      bottomList.add(ls);
    });

    return bottomList;
  }

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
        child: LayoutBuilder(builder: (context, constraints) {
          if(_selectedIndex != 0){
            return _widgetOptions.elementAt(_selectedIndex - 1);  //Narbar跳转到其它页面
          }else{
            return ListView(  //主页内容
                children: [
                topBanner(),
                threeButtons(),
                textTitle(),
                FutureBuilder<List<List<String>>>(
                  future: getRequest(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      List<List<String>> myList = snapshot.data!;
                      return ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: myList.length,
                        itemBuilder: (context, index) {
                          if(index % 2 == 0){
                            return bottomView1(myList[index][0], myList[index][1], myList[index][2]);
                          }else{
                            return bottomView2(myList[index][0], myList[index][1], myList[index][2]);
                          }
                          },
                        );
                    }
                    return Container();  //无数据，返回空
                  },
                )
                ],
              );
          }
        },),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onNavBarItemTapped,
      ),
    );
  }
}
