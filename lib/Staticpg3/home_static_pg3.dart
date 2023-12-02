import 'package:flutter/material.dart';

class ImageDataModel {
  final String imageUrl;
  final String description;

  ImageDataModel({required this.imageUrl, required this.description});
}

class HomeStaticPage3 extends StatelessWidget {
  final List<ImageDataModel> images = [
    ImageDataModel(
      imageUrl: 'https://example.com/image1.png',
      description: 'Description for Image 1',
    ),
    ImageDataModel(
      imageUrl: 'https://example.com/image2.png',
      description: 'Description for Image 2',
    ),
    ImageDataModel(
      imageUrl: 'https://example.com/image3.png',
      description: 'Description for Image 3',
    ),
    // Add more images as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Boxes'),
      ),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _buildImageBox(images[index]);
        },
      ),
    );
  }

  Widget _buildImageBox(ImageDataModel imageDataModel) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
            child: Text(
              'Title ${images.indexOf(imageDataModel) + 1}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 100.0, // Adjust the width as needed
            height: 100.0, // Adjust the height as needed
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageDataModel.imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Text(
                imageDataModel.description,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}