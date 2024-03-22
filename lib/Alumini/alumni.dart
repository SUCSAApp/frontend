import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumniPage extends StatefulWidget {
  const AlumniPage({Key? key}) : super(key: key);

  @override
  State<AlumniPage> createState() => _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  final Color myColor = const Color.fromRGBO(29, 32, 136, 1.0);

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> fetchAlumniActivities() async {
    final response = await http.post(
      Uri.parse('https://sucsa.org:8004/api/public/alumniActivities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData['data'];
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Widget _buildActivities(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchAlumniActivities(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0), // Outer margin for the blue container
            decoration: BoxDecoration(
              color: myColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              title: Text(
                '校友会活动', // "Alumni Activities" in English
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: snapshot.data!.map<Widget>((activity) {
                return _buildActivityTile(context, activity);
              }).toList(),
            ),
          );
        } else {
          return const Text('No activities found');
        }
      },
    );
  }



  Widget _buildActivityTile(BuildContext context, dynamic activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Card(
        elevation: 5.0,
        child: Column(
          children: [
            Image.network(
              activity['img'] ?? 'https://via.placeholder.com/150', // Placeholder image
              width: double.infinity,
              height: 500,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] ?? 'Title not available',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    activity['description'] ?? 'Description not available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> loadAlumniOrganizations() async {
    final String response = await rootBundle.loadString('lib/assets/data/alumni_info.json');
    return json.decode(response);
  }

  Widget _buildAlumniOverview() {
    return FutureBuilder<List<dynamic>>(
      future: loadAlumniOrganizations(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return _buildAlumniOverviewTile('校友会一览', snapshot.data!);
        } else {
          return Text('No data found');
        }
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 420,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage('lib/assets/alumni_map.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildIntroTile('校友会简介', '悉尼大学中国学联校友会（简称学联校友会）是由悉尼大学中国学生学者联合会（简称悉大学联）延伸成立的校友会组织。学联校友会旨在为悉尼大学海内外新老毕业校友，悉大学联毕业会员，干事，提供优质校友服务。学联校友会以行业为导向，以事业发展为目的定期举办公益活动。学联校友会希望成为集具价值，信任感和归属感的校友社区，为校友提供有活力的校友交流和其他多元交流机会。探索大学校友NGO组织长期可持续发展与校友组织支持校友发展相结合的创新模式。海内存知已，天涯若比邻。南半球美丽的蓝花楹已然成为你我最难忘的回忆，希望未来我们也能一起携手并进！学联校友会会员目前仅针对已毕业校友开放，所有已毕业校友均可免费注册成为校友会会员。成为会员可以参加校友会活动，加入校友会行业社群。'),
          const SizedBox(height: 20),
          _buildAlumniOverview(),
          const SizedBox(height: 20),
          _buildActivities(context),
        ],
      ),
    );
  }


  Widget _buildAlumniOverviewTile(String title, List<dynamic> alumniData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0), // Outer margin for the blue container
      decoration: BoxDecoration(
        color: myColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: alumniData.map<Widget>((alumni) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              width: 300, // Fixed width set to 80% of screen width
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        alumni['name'] ?? 'No Name Provided',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8.0),
                      SelectableText(alumni['Contact'] ?? 'No Contact Provided'),
                      SizedBox(height: 4.0),
                      SelectableText(alumni['phoneNumber'] ?? 'No Phone Provided'),
                      SizedBox(height: 4.0),
                      SelectableText(alumni['Wechat'] ?? 'No Wechat Provided'),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildIntroTile(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: myColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SelectableText(
                content,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }


}








