import 'package:diyabet/screens/note/note_screen.dart';
import 'package:flutter/material.dart';
import 'package:diyabet/screens/calender/calneder_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  // Sayfalar listesi
  final List<Widget> _pages = [
    CalendarPage(),
    NoteScreen(),
    ValuesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Üstteki Navigasyon Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(19, 69, 122, 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavButton(
                  label: "Takvim",
                  index: 0,
                  icon: Icons.calendar_today,
                ),
                _buildNavButton(
                  label: "Notlarım",
                  index: 1,
                  icon: Icons.note,
                ),
                _buildNavButton(
                  label: "Değerlerim",
                  index: 2,
                  icon: Icons.bar_chart,
                ),
              ],
            ),
          ),
          // Seçilen sayfa görüntülenir
          Expanded(
            child: _pages[_selectedPageIndex],
          ),
        ],
      ),
    );
  }

  // Navigasyon Butonu Yapılandırma
  Widget _buildNavButton({required String label, required int index, required IconData icon}) {
    final isSelected = _selectedPageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPageIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 24),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Değerlerim Sayfası
class ValuesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Değerlerim Sayfası",
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
