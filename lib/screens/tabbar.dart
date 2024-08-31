import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:diyabet/screens/reminder/reminder_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diyabet/screens/home/home_page.dart';
import 'package:diyabet/screens/profile/profile_page.dart';
import 'package:diyabet/screens/diabet/diabet_screen.dart';
import 'package:diyabet/screens/diet/diet_screen.dart';
import 'package:diyabet/screens/settings/settings_screen.dart';
import '../models/med_model.dart';
import 'calender/calneder_page.dart';
import 'info/info.dart'; // Import the settings screen

import 'med/medicine_page.dart'; // Import MedicinePage

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();

}

class _TabBarScreenState extends State<TabBarScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _animationController;
  List<MedModel> _medications = [];





  final List<Widget> _widgetOptions = <Widget>[
    CalendarPage(),
    ProfilePage(),
    DiabetesScreen(),
    InfoPage(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.person,
    Icons.healing,
    Icons.restaurant,
  ];

  final textList = <String>[
    'Home',
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
    _fetchMedications();
  }

  // Fetch medications from Firestore
  void _fetchMedications() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<MedModel> meds = await MedModel.getMedications(user.uid);
      setState(() {
        _medications = meds;
      });
    }
  }

  Future<void> _navigateToMedicinePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicinePage()),
    );

    if (result != null && result is MedModel) {
      setState(() {
        _medications.add(result);
      });
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind AppBar
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(
                textList[_selectedIndex],
                style: const TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: Color.fromRGBO(19, 69, 122, 1.0), // Custom color
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
            Flexible(
              child: Stack(
                children: [
                  // Black overlay background
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  // Main content
                  Center(
                    child: _widgetOptions.elementAt(_selectedIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToMedicinePage,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        child: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? Color.fromRGBO(19, 69, 122, 1.0) : Colors.grey;
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
          splashColor: Color.fromRGBO(19, 69, 122, 1.0),
          notchAndCornersAnimation: _animationController!,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
