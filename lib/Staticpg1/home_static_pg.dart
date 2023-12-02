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
      name: 'Organization 1',
      logoUrl: 'https://example.com/logo1.png',
      description: 'Description of Organization 1.',
      link: 'https://example.com/organization1',
    ),
    Organization(
      name: 'Organization 2',
      logoUrl: 'https://example.com/logo2.png',
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