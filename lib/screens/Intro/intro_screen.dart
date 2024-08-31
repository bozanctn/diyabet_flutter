import 'package:diyabet/screens/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> _titles = [
    'Hoşgeldiniz!',
    'Özelliklerimiz',
    'Kolay Kullanım',
    'Başlayalım!',
    'Keşfet',
    'Yenilikler',
    'Hadi Başlayalım'
  ];

  final List<String> _descriptions = [
    'Uygulamamıza hoşgeldiniz. Size en iyi deneyimi sunmak için buradayız.',
    'Uygulamamızın sunduğu harika özellikleri keşfedin.',
    'Kullanımı kolay ve anlaşılır arayüzümüz ile hemen başlayın.',
    'Artık uygulamayı keşfetmeye hazırsınız. Hadi başlayalım!',
    'Farklı özelliklerimizi keşfedin.',
    'Yenilikleri keşfedin.',
    'Şimdi başlama zamanı!'
  ];

  final List<String> _images = [
    'assets/1.png',
    'assets/2.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
    'assets/6.png',
    'assets/7.png',
  ];

  final List<Color> _backgroundColors = [
    const Color(0xFFE3F2FD), // Soft blue
    const Color(0xFFFFF3E0), // Soft orange
    const Color(0xFFE8F5E9), // Soft green
    const Color(0xFFFFEBEE), // Soft red
    const Color(0xFFF3E5F5), // Soft purple
    const Color(0xFFFFFDE7), // Soft yellow
    const Color(0xFFE0F7FA), // Soft cyan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColors[_currentIndex],
      appBar: AppBar(
        backgroundColor: _backgroundColors[_currentIndex],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TabBarScreen()),
              );
            },
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'UbuntuSans'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _titles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(_images[index], fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _titles[index],
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'UbuntuSans'
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _descriptions[index],
                        style: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'UbuntuSans', fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: _titles.length,
            effect: const WormEffect(
              dotColor: Colors.black54,
              activeDotColor: Colors.black,
              dotHeight: 12,
              dotWidth: 12,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () {
                if (_currentIndex == _titles.length - 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TabBarScreen()),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700, // Buton arka plan rengi
              ),
              child: Text(
                _currentIndex == _titles.length - 1 ? 'Başla' : 'Devam',
                style: TextStyle(color: _backgroundColors[_currentIndex], fontWeight: FontWeight.normal, fontSize: 16, fontFamily: 'UbuntuSans'),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
