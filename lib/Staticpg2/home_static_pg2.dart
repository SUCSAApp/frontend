import 'dart:io';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Change these folder paths to your actual folder paths
  final List<String> folderPaths = ['.../app/合作学联', '.../app/NGo', '.../app/社团'];
  int selectedFolderIndex = 0;

  List<String> getImagePaths(String folderPath) {
    Directory directory = Directory(folderPath);
    List<FileSystemEntity> files = directory.listSync();
    List<String> imagePaths = [];

    for (var file in files) {
      if (file.path.endsWith('.png')) {
        imagePaths.add(file.path);
      }
    }

    return imagePaths;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logo Viewer'),
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            children: List.generate(
              folderPaths.length,
                  (index) => Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFolderIndex = index;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: index == selectedFolderIndex
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  child: Text('Folder ${index + 1}'),
                ),
              ),
            ),
          ),
          // Image Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // You can adjust the number of columns
              ),
              itemCount: getImagePaths(folderPaths[selectedFolderIndex]).length,
              itemBuilder: (context, index) {
                String imagePath =
                getImagePaths(folderPaths[selectedFolderIndex])[index];
                return Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}