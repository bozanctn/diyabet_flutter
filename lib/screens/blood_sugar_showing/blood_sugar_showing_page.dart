import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../sugar_measurement/sugar_measurement_page.dart';

class BloodSugarDataPage extends StatefulWidget {
  @override
  _BloodSugarDataPageState createState() => _BloodSugarDataPageState();
}

class _BloodSugarDataPageState extends State<BloodSugarDataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() async {
    QuerySnapshot snapshot = await _firestore.collection('blood_sugar_entries').get();
    setState(() {
      _entries = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Save document ID for deletion
          'sugarLevel': doc['sugar_level'],
          'insulinUnits': doc['insulin_units'],
        };
      }).toList();
    });
  }

  void _addEntry(int sugarLevel, double insulinUnits) async {
    await _firestore.collection('blood_sugar_entries').add({
      'sugar_level': sugarLevel,
      'insulin_units': insulinUnits,
      'timestamp': Timestamp.now(),
    });
    _loadEntries(); // Reload entries after adding a new one
  }

  void _deleteEntry(String id) async {
    await _firestore.collection('blood_sugar_entries').doc(id).delete();
    _loadEntries(); // Reload entries after deletion
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Blood Sugar Data',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Entries'),
              Tab(text: 'Add Entry'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab (Blood Sugar Data)
            Container(
              color: const Color.fromRGBO(19, 69, 122, 1.0),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white, // DataTable background color
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Blood Sugar (mg/dL)')),
                              const DataColumn(label: Text('Insulin Units')),
                              const DataColumn(label: Text('Actions')), // Actions column for delete
                            ],
                            rows: _entries.map((entry) {
                              return DataRow(cells: [
                                DataCell(Text(entry['sugarLevel'].toString())),
                                DataCell(Text(entry['insulinUnits'].toString())),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteEntry(entry['id']);
                                    },
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Second tab (Blood Sugar Entry Page)
            BloodSugarEntryPage(onEntryAdded: _addEntry),
          ],
        ),
      ),
    );
  }
}
