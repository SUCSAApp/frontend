import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaModel {
  final String appIconUrl;
  final String description;
  final String deepLinkUrl; // This is the URI scheme or deep link URL

  SocialMediaModel({
    required this.appIconUrl,
    required this.description,
    required this.deepLinkUrl,
  });
}

class HomeStaticPage3 extends StatelessWidget {
  final List<SocialMediaModel> socialMediaApps = [
    SocialMediaModel(
      appIconUrl: 'lib/assets/media/xhs.png', // Local asset for the app icon
      description: '学联官方小红书 -- 学联在小红书平台官方账号发布最新活动信息，各专业学科导师分享，及学生手册内容更新。同时持续为同学们在线答疑解惑。',
      deepLinkUrl: 'https://www.xiaohongshu.com/user/profile/5ebe58a8000000000101d766', // Replace with actual profile URI scheme
    ),
    SocialMediaModel(
      appIconUrl: 'lib/assets/media/xhs.png', // Local asset for the app icon
      description: '学联舞团小红书 -- 悉尼大学中国学联舞团Dozer Space在小红书发布舞团成员表演和团队作品视频。',
      deepLinkUrl: 'https://www.xiaohongshu.com/user/profile/60164e890000000001002541', // Replace with actual profile URI scheme
    ),
    SocialMediaModel(
        appIconUrl: 'lib/assets/media/bili.png',
        description: '悉尼大学中国学联在bilibili平台发布舞团、乐团作品展示、活动直播和活动花絮视频等媒体内容，展现留学生活的多彩魅力。',
        deepLinkUrl: 'https://space.bilibili.com/515192990?spm_id_from=333.337.0.0)'
    ),
    SocialMediaModel(
        appIconUrl: 'lib/assets/media/ins.jpeg',
        description: '学联官方Instagram账号功能为更新学联活动双语讯息，让更多元化的学生认识，关注，并加入学联。同时，此账号也提供学联与澳洲本地和国际合作机会。',
        deepLinkUrl: 'https://www.instagram.com/usydsucsa/'
    ),
    SocialMediaModel(
        appIconUrl: 'lib/assets/media/tk.png',
        description: '学联官方抖音账号通过短视频形式展现学联多样风采。这里有轻松有趣的小剧场，多才多艺的文艺show，和学联活动回顾。期待你的持续关注！',
        deepLinkUrl: 'https://www.douyin.com/user/MS4wLjABAAAAX79uCGx4_uDYZew5cRHws9K8F5YoZCRyYJepMs6irAE'
    ),
    SocialMediaModel(
        appIconUrl: 'lib/assets/media/xmly.png',
        description: '悉尼大学中国学联小声叨叨电台，由文艺部成员创办、管理和运营，由学联其他职能部门辅助运营。目前电台由播客形式定期在喜马拉雅上平台发布内容。重新定义文艺，传播文艺感受，收获治愈瞬间。',
        deepLinkUrl: 'https://m.ximalaya.com/zhubo/467946653'
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('学联媒体平台', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: ListView.builder(
        itemCount: socialMediaApps.length,
        itemBuilder: (context, index) {
          return _buildSocialMediaBox(context, socialMediaApps[index]);
        },
      ),
    );
  }

  Widget _buildSocialMediaBox(BuildContext context, SocialMediaModel socialMediaModel) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  socialMediaModel.appIconUrl,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16.0), // Spacing between the image and the text
                Expanded(
                  child: Text(
                    socialMediaModel.description,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => _launchURL(socialMediaModel.deepLinkUrl),
                child: Text(
                  '访问主页', // Text for the button
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(29, 32, 136, 1.0), // Text color for the button
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
