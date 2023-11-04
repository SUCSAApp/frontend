import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _currentIndex = 0;
  final List<String> _images = ["lib/assets/图书馆.png", "lib/assets/摆摊.png"];
  late final PageController _pageController;

  var pastAct = const Text("往期活动",
    style: TextStyle(
      fontSize: 20, // Adjust the font size as needed
      fontWeight: FontWeight.bold, // Adjust the style as needed
    )
  );


  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) { // 使用新的 canLaunchUrl
      await launchUrl(uri); // 使用新的 launchUrl
    } else {
      throw 'Could not launch $url';
    }
  }

  InkWell activity(String title, String date, String img, String url) {
    return InkWell(
      onTap: () {
      },
      child: Stack(
        children: <Widget>[
          // 图片背景
          Container(
            width: 400,
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(img), // 替换为您的图片路径
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey, // 阴影颜色
                  blurRadius: 5.0, // 阴影模糊半径
                  spreadRadius: 2.0, // 阴影扩散半径
                  offset: Offset(0, 2), // 阴影偏移量
                ),
              ],
            ),
          ),

          // 颜色填充
          Positioned(
            top: 120, // 调整颜色填充的位置
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white, // 替换为您想要的颜色
            ),
          ),

          // 写上颜色
          Positioned(
            top: 135, // 调整文本的位置
            left: 0,
            right: 260,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black, // 文本颜色
                  fontSize: 14, // 文本字体大小
                ),
              ),
            ),
          ),
          Positioned(
            top: 155, // 调整文本的位置
            left: 0,
            right: 260,
            child: Center(
              child: Text(
                date,
                style: const TextStyle(
                  color:  Color.fromRGBO(107, 107, 107, 1.0), // 文本颜色
                  fontSize: 10, // 文本字体大小
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5, // 调整按钮的位置
            left: 230,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 27, 34, 140), // 设置按钮的背景颜色
                  minimumSize: const Size(100, 30), // 设置按钮的最小宽度和高度
                  fixedSize: const Size(100, 30), // 设置按钮的确切宽度和高度
                ),
                onPressed: () {
                  launchURL(url); // 调用打开网页链接的函数
                  // 在按钮被点击时执行的操作
                },
                child: const Text(
                  '了解更多',
                  style:
                  TextStyle(
                    color: Colors.white, // 文本颜色
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // 文本字体大小
                  ),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
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
            // Rest of your content goes here
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20, bottom: 10), // 调整左侧内边距
              child: pastAct,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30), // 调整左侧内边距
              child:Center(child:activity("此刻音乐节", "2023.02.12", "lib/assets/图书馆.png",
                  "https://www.figma.com/file/oAunUVThglsFpBKpAd8aJB/SUCSA-APP?type=design&node-id=18-3&mode=design&t=ITi1uqwSrfw3BMlt-0")),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30), // 调整左侧内边距
              child:Center(child:activity("「悉望」新生分享会", "2023.02.12", "lib/assets/摆摊.png",
                  "https://www.figma.com/file/oAunUVThglsFpBKpAd8aJB/SUCSA-APP?type=design&node-id=18-3&mode=design&t=ITi1uqwSrfw3BMlt-0")),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10), // 调整左侧内边距
              child:Center(child:activity("「悉望」新生分享会", "2023.02.12", "lib/assets/图书馆.png",
                  "https://www.figma.com/file/oAunUVThglsFpBKpAd8aJB/SUCSA-APP?type=design&node-id=18-3&mode=design&t=ITi1uqwSrfw3BMlt-0")),
            ),
          ],
        ),
      ),
    );
  }
}
