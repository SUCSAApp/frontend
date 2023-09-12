import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _currentIndex = 0;
  final List<String> _images = ["lib/assets/图书馆.png", "lib/assets/摆摊.png"];
  late final PageController _pageController;

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
            // Rest of your content goes here
          ],
        ),
      ),
    );
  }
}
