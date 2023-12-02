import 'package:flutter/material.dart';

class IconDataModel {
  final IconData iconData;
  final String description;

  IconDataModel({required this.iconData, required this.description});
}

class HomeStaticPage2 extends StatefulWidget {
  @override
  _HomeStaticPage2State createState() => _HomeStaticPage2State();
}

class _HomeStaticPage2State extends State<HomeStaticPage2> {
  int selectedCategoryIndex = 0;

  final List<List<IconDataModel>> categories = [
    [
      IconDataModel(iconData: Icons.restaurant, description: 'Food'),
      IconDataModel(iconData: Icons.shopping_cart, description: 'Shopping'),
      IconDataModel(iconData: Icons.local_parking, description: 'Parking'),
    ],
    [
      IconDataModel(iconData: Icons.movie, description: 'Movies'),
      IconDataModel(iconData: Icons.music_note, description: 'Music'),
      IconDataModel(iconData: Icons.sports, description: 'Sports'),
    ],
    [
      IconDataModel(iconData: Icons.book, description: 'Books'),
      IconDataModel(iconData: Icons.brush, description: 'Art'),
      IconDataModel(iconData: Icons.computer, description: 'Technology'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Categories'),
      ),
      body: Column(
        children: [
          _buildCategoryButtons(),
          Expanded(
            child: _buildIconGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(
        categories.length,
            (index) => ElevatedButton(
          onPressed: () {
            setState(() {
              selectedCategoryIndex = index;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return selectedCategoryIndex == index
                    ? Colors.blue
                    : Colors.grey;
              },
            ),
          ),
          child: Text('Category ${index + 1}'),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: categories[selectedCategoryIndex].length,
      itemBuilder: (context, index) {
        IconDataModel iconDataModel = categories[selectedCategoryIndex][index];
        return _buildIconCard(iconDataModel);
      },
    );
  }

  Widget _buildIconCard(IconDataModel iconDataModel) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconDataModel.iconData,
            size: 48.0,
          ),
          SizedBox(height: 8.0),
          Text(
            iconDataModel.description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}