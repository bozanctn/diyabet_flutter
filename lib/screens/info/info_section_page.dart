import 'package:flutter/material.dart';
import 'package:diyabet/screens/info/info_data.dart';
import 'package:diyabet/screens/info/info_result_page.dart';

class InfoSectionPage extends StatefulWidget {
  const InfoSectionPage({super.key});

  @override
  _InfoSectionPageState createState() => _InfoSectionPageState();
}

class _InfoSectionPageState extends State<InfoSectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _items = infoData.keys.toList();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items;
    _searchController.addListener(() {
      _filterItems();
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ara..?',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      color: Colors.pinkAccent.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.info_outline, color: Colors.white),
                        title: Text(
                          _filteredItems[index],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          // Seçilen öğeyi InfoResultPage'e aktar
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoResultPage(
                                title: _filteredItems[index],
                                description: infoData[_filteredItems[index]] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
