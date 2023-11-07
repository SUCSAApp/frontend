import 'package:flutter/material.dart';

class AlumniPage extends StatelessWidget {
  const AlumniPage({super.key});

  // 自定义颜色
  final Color myColor = const Color.fromRGBO(29, 32, 136, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索校友信息',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // 缩小图片的容器
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: 420, // 设置图片高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: AssetImage('lib/assets/alumni_map.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTile('校友会简介', '悉尼大学中国学联校友会（简称学联校友会）是由悉尼大学中国学生学者联合会（简称悉大学联）延伸成立的校友会组织。学联校友会旨在为悉尼大学海内外新老毕业校友，悉大学联毕业会员，干事，提供优质校友服务。学联校友会以行业为导向，以事业发展为目的定期举办公益活动。学联校友会希望成为集具价值，信任感和归属感的校友社区，为校友提供有活力的校友交流和其他多元交流机会。探索大学校友NGO组织长期可持续发展与校友组织支持校友发展相结合的创新模式。海内存知已，天涯若比邻。南半球美丽的蓝花楹已然成为你我最难忘的回忆，希望未来我们也能一起携手并进！学联校友会会员目前仅针对已毕业校友开放，所有已毕业校友均可免费注册成为校友会会员。成为会员可以参加校友会活动，加入校友会行业社群。'),
          const SizedBox(height: 10),
          _buildTile('校友会一览', '校友会列表和相关信息。'),
          const SizedBox(height: 10),
          _buildTile('校友会活动', '这里列出了校友会的近期活动。'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget _buildTile(String title, String content) {
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
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(fontWeight: FontWeight.normal), // 内容使用普通字体
              ),
            ),
          ),
        ],
      ),
    );
  }
}


