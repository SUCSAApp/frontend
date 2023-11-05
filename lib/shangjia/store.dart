import 'package:flutter/material.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  int _currentIndex = 0;
  final List<String> _images = ["lib/assets/图书馆.png", "lib/assets/摆摊.png"];
  late final PageController _pageController;

  // Default to grid view
  bool _isListView = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Auto-scrolling functionality
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      _currentIndex = (_currentIndex + 1) % _images.length;

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );

      return true; // return true to repeat, false to stop
    });
  }

  // Toggle between list and grid view

  void _switchToListView() {
    setState(() {
      _isListView = true;
    });
  }

  void _switchToGridView() {
    setState(() {
      _isListView = false;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商家'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: _images.length,
                controller: _pageController,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.asset(
                        _images[index],
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _switchToGridView,
                    icon: Icon(Icons.grid_view),
                    iconSize: 30.0, // Set width and height to be equal
                  ),
                  SizedBox(width: 0), // Small gap between the two icons
                  IconButton(
                    onPressed: _switchToListView,
                    icon: Icon(Icons.list),
                    iconSize: 40.0, // Set width and height to be equal
                  ),
                ],
    // """get info from backend"""
      // FutureBuilder<List<ListItem>>(
      // future: fetchListItems(),
      // builder: (context, snapshot) {
      // if (snapshot.connectionState == ConnectionState.waiting) {
      // return CircularProgressIndicator();
      // } else if (snapshot.hasError) {
      // return Text('Error: ${snapshot.error}');
      // } else {
      //
      // final items = snapshot.data!;
      // return _isListView ? _buildListView(items) : _buildGridView(items);
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _toggleView,
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                ),
                child: Icon(_isListView ? Icons.grid_view : Icons.list),

              ),
            ),
            // The default view is now GridView
            _isListView ? _buildListView() : _buildGridView(),
          ],
        ),
      ),
    );
  }

  // Build list view
  Widget _buildListView() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 20,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey, // Set the color of the line
        height: 1, // Set the thickness of the line
      ),
      itemBuilder: (context, index) => ListTile(
        title: Text('佩姐火锅 $index 号'),
//     return ListView.builder(
//       physics: const NeverScrollableScrollPhysics(), // to disable ListView's own scrolling
//       shrinkWrap: true, // Use this to fit the ListView in the SingleChildScrollView
//       itemCount: 20,
//       itemBuilder: (context, index) => ListTile(
//         title: Text('列表项 $index'),

      ),
    );
  }

  // Build grid view
  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(10.0), // Add padding to create gaps
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: 16.0, // Vertical gap between grid items
          crossAxisSpacing: 16.0, // Horizontal gap between grid items
        ),
        itemCount: 20,
        itemBuilder: (context, index) => GridTile(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                Text('佩姐火锅 $index 号'),
              ],
            ),
          ),
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(), // to disable GridView's own scrolling
//       shrinkWrap: true, // Use this to fit the GridView in the SingleChildScrollView
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: 20,
//       itemBuilder: (context, index) => GridTile(
//         child: Container(
//           alignment: Alignment.center,
//           child: Text('网格项 $index'),
        ),
      ),
    );
  }
}
