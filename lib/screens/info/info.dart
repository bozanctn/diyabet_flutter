import 'package:flutter/material.dart';
import 'info2.dart';
import 'info3.dart';
import 'info4.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _items = [
    'Diyabet Nedir?',
    'Diyabet Türleri',
    'Diyabet Yönetimi',
    'Diyabetle İlgili İpuçları',
  ];
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
      backgroundColor: Color.fromRGBO(19, 69, 122, 1.0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Ara..?',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                        leading: Icon(Icons.info_outline, color: Colors.white),
                        title: Text(
                          _filteredItems[index],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'İşte minik bilgiler fln var aq',
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          switch (_filteredItems[index]) {
                            case 'Diyabet Nedir?':
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InfoPage()),
                              );
                              break;
                            case 'Diyabet Türleri':
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ArticlePage1()),
                              );
                              break;
                            case 'Diyabet Yönetimi':
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ArticlePage2()),
                              );
                              break;
                            case 'Diyabetle İlgili İpuçları':
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ArticlePage3()),
                              );
                              break;
                          }
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
