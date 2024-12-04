import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diyabet/screens/profile/profile_page.dart';
import 'package:diyabet/screens/diabet/diabet_screen.dart';
import 'package:diyabet/screens/settings/settings_screen.dart';
import 'package:diyabet/screens/info/info_section_page.dart';
import '../models/med_model.dart';
import 'package:diyabet/screens/home/home_page.dart';
import 'package:diyabet/screens/medicine/medicine_page.dart';

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationController? _animationController;
  List<MedModel> _medications = [];

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    DiabetesScreen(),
    const InfoSectionPage(),
    ProfilePage(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.healing,
    Icons.question_mark,
    Icons.person,
  ];

  final textList = <String>[
    'Ana Sayfa',
    'İlaçlar',
    'S.S.S',
    'Profil'
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
    _fetchMedications();
  }

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          textList[_selectedIndex],
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: () {
              // Bilgi mesajı için bir dialog gösteriliyor
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Bilgilendirme',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    content: const Text(
                      'Silme işlemleri sağa kaydırılarak yapılabilir. Her işlem öncesinde bir onay mesajı alacaksınız.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Tamam',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: _widgetOptions.elementAt(_selectedIndex),
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
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? Colors.white : Colors.white38;
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
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
        activeIndex: _selectedIndex,
        splashColor: const Color.fromRGBO(19, 69, 122, 1.0),
        notchAndCornersAnimation: _animationController!,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: _onItemTapped,
      ),
    );
  }
}
