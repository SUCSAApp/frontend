import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int selectedPageIndex = 0;
  TabController? _tabController;
  final List<List<String>> folderImagePaths = [
    [
      'lib/assets/cooperator/co1.jpg',
      'lib/assets/cooperator/co2.jpg',
      'lib/assets/cooperator/co3.png',
      'lib/assets/cooperator/co4.png',
      'lib/assets/cooperator/co5.png',
      'lib/assets/cooperator/co6.png',
      'lib/assets/cooperator/co7.png',
      'lib/assets/cooperator/co8.png',
      'lib/assets/cooperator/co9.png',
      'lib/assets/cooperator/co10.png',
      'lib/assets/cooperator/co11.png',
      'lib/assets/cooperator/co12.png',
      'lib/assets/cooperator/co13.png',
    ],
    [
      'lib/assets/ngo/ngo1.png',
      'lib/assets/ngo/ngo2.png',
      'lib/assets/ngo/ngo3.png',
      'lib/assets/ngo/ngo4.png',
      'lib/assets/ngo/ngo5.png',
      'lib/assets/ngo/ngo6.png',
      'lib/assets/ngo/ngo7.png',
    ],
    [
      'lib/assets/clubs/school1.png',
      'lib/assets/clubs/school2.png',
      'lib/assets/clubs/school3.png',
      'lib/assets/clubs/school4.png',
      'lib/assets/clubs/school5.png',
      'lib/assets/clubs/school6.png',
      'lib/assets/clubs/school8.png',
      'lib/assets/clubs/school9.png',
      'lib/assets/clubs/school10.png',
      'lib/assets/clubs/school11.png',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: folderImagePaths.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '第三方合作',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: Column(
        children: [
          SizedBox(height: 10.0),
          // Button bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPageButton('合作学联', 0),
              _buildPageButton('NGO', 1),
              _buildPageButton('合作社团', 2),
            ],
          ),
          Expanded(
            // Display the grid of images based on the selected index
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: folderImagePaths[selectedPageIndex].length,
              itemBuilder: (context, index) {
                String assetPath = folderImagePaths[selectedPageIndex][index];
                return Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(String title, int index) {
    bool isSelected = selectedPageIndex == index;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedPageIndex = index;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Color.fromRGBO(29, 32, 136, 1.0), fontWeight: FontWeight.bold // Text color
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) {
            if (states.contains(MaterialState.pressed) || isSelected) {
              return Color.fromRGBO(29, 32, 136, 1.0);
            }
            return Colors.white;
          },
        ),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: Color.fromRGBO(29, 32, 136, 1.0)),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        elevation: MaterialStateProperty.all(0), // Remove shadow
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }

}
