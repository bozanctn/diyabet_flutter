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
          'id': doc.id,
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
    _loadEntries();
  }

  void _deleteEntry(String id) async {
    await _firestore.collection('blood_sugar_entries').doc(id).delete();
    _loadEntries();
  }

  void _showA1cDialog(double avgSugarLevel) {
    // Calculate HbA1c and estimated average glucose (eAG)
    double hbA1c = (avgSugarLevel + 46.7) / 28.7;
    double eAG = (28.7 * hbA1c) - 46.7;

    // Show the result in a popup dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('HbA1c and Average Blood Sugar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estimated HbA1c: ${hbA1c.toStringAsFixed(2)}%'),
              SizedBox(height: 10),
              Text('Estimated Average Glucose (eAG): ${eAG.toStringAsFixed(2)} mg/dL'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _calculateA1c() {
    if (_entries.isNotEmpty) {
      // Calculate average blood sugar level from the entries
      double totalSugarLevel = 0;
      for (var entry in _entries) {
        totalSugarLevel += entry['sugarLevel'];
      }
      double avgSugarLevel = totalSugarLevel / _entries.length;

      // Show the HbA1c and average glucose in a dialog
      _showA1cDialog(avgSugarLevel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No entries available to calculate HbA1c')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                      color: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Blood Sugar (mg/dL)')),
                              const DataColumn(label: Text('Insulin Units')),
                              const DataColumn(label: Text('Actions')),
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
                  ElevatedButton(
                    onPressed: _calculateA1c,
                    child: Text('Calculate HbA1c & Average Sugar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
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
