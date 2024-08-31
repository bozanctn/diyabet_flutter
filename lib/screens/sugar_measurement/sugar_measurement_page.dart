import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodSugarEntryPage extends StatefulWidget {
  final Function(int sugarLevel, double insulinUnits) onEntryAdded;

  BloodSugarEntryPage({required this.onEntryAdded});

  @override
  _BloodSugarEntryPageState createState() => _BloodSugarEntryPageState();
}

class _BloodSugarEntryPageState extends State<BloodSugarEntryPage> {
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveEntry() async {
    if (_sugarController.text.isNotEmpty && _insulinController.text.isNotEmpty) {
      int sugarLevel = int.parse(_sugarController.text);
      double insulinUnits = double.parse(_insulinController.text);

      // Save data to Firestore
      await _firestore.collection('blood_sugar_entries').add({
        'sugar_level': sugarLevel,
        'insulin_units': insulinUnits,
        'timestamp': Timestamp.now(),
      });

      widget.onEntryAdded(sugarLevel, insulinUnits);

      // Clear the fields after saving
      _sugarController.clear();
      _insulinController.clear();

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields.')),
      );
    }
  }

  void _deleteEntry(String id) async {
    await _firestore.collection('blood_sugar_entries').doc(id).delete();

    // Manually refresh the UI
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _sugarController,
            decoration: InputDecoration(
              labelText: 'Blood Sugar (mg/dL)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _insulinController,
            decoration: InputDecoration(
              labelText: 'Insulin Units',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveEntry,
            child: Text('Save Entry'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('blood_sugar_entries').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var entries = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    var entry = entries[index];
                    var sugarLevel = entry['sugar_level'];
                    var insulinUnits = entry['insulin_units'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text('Blood Sugar: $sugarLevel mg/dL'),
                        subtitle: Text('Insulin: $insulinUnits units'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEntry(entry.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
