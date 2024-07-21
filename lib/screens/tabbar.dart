import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'package:diyabet/screens/home/home_page.dart';
import 'package:diyabet/screens/login/login_screen.dart';
import 'package:diyabet/screens/profile/profile_page.dart';
import 'package:diyabet/screens/diabet/diabet_screen.dart';
import 'package:diyabet/screens/diet/diet_screen.dart';

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    LoginScreen(),
    ProfilePage(),
    DiabetScreen(),
    DietScreen(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.login,
    Icons.person,
    Icons.healing,
    Icons.restaurant,
  ];

  final textList = <String>[
    'Home',
    'Login',
    'Profile',
    'Diyabet',
    'Diet',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sağlık Uygulaması'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.blue : Colors.grey;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                textList[index],
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              )
            ],
          );
        },
        backgroundColor: Colors.white,
        activeIndex: _selectedIndex,
        splashColor: Colors.blue,
        notchAndCornersAnimation: new AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        ),
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        onTap: _onItemTapped,
        // Diğer parametreler
      ),
    );
  }
}
