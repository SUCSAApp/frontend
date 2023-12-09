import 'package:flutter/material.dart';

class HomeStaticPage1 extends StatefulWidget {
  const HomeStaticPage1({super.key});

  @override
  State<HomeStaticPage1> createState() => _HomeStaticPage1State();
}

class Organization {
  final String name;
  final String logoUrl;
  final String description;
  final String link;

  Organization({
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.link,
  });
}
class _HomeStaticPage1State extends State<HomeStaticPage1> {
  final List<Organization> organizations = [
    Organization(
      name: '新南华辩社',
      logoUrl: '.../app/school9.png',
      description: 'Description of Organization 1.',
      link: 'https://example.com/organization1',
    ),
    Organization(
      name: '中国心理学生协会',
      logoUrl: '.../app/school10.png',
      description: 'Description of Organization 2.',
      link: 'https://example.com/organization2',
    ),
    Organization(
      name: 'ACYA',
      logoUrl: '.../app/school11.png',
      description: 'Description of Organization 2.',
      link: 'https://example.com/organization2',
    ),
    // Add more organizations as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizations'),
      ),
      body: ListView.builder(
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          return _buildOrganizationCard(context, organizations[index]);
        },
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context, Organization organization) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            organization.logoUrl,
            height: 100.0, // Adjust the height as needed
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              organization.description,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to the organization's link
            },
            child: Text('Learn More'),
          ),
        ],
      ),
    );
  }
}