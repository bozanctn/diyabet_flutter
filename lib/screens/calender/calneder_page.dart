import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:diyabet/screens/calender/calendar_event_model.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _markedDays = {}; // İşaretli günlerin etkinlikleri

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Event> _selectedEvents = []; // Seçilen günün etkinlikleri

  @override
  void initState() {
    super.initState();
    _fetchMonthEvents(_focusedDay); // İlk ayın etkinliklerini yükle
  }

  Future<void> _fetchMonthEvents(DateTime month) async {
    if (_auth.currentUser == null) return;

    final userUid = _auth.currentUser!.uid;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final snapshot = await _firestore
        .collection('Users')
        .doc(userUid)
        .collection('Notes')
        .where(FieldPath.documentId,
        isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
        isLessThanOrEqualTo: endOfMonth.toIso8601String())
        .get();

    Map<DateTime, List<Event>> fetchedMarkedDays = {};

    for (var doc in snapshot.docs) {
      final day = DateTime.parse(doc.id);
      final eventsSnapshot = await _firestore
          .collection('Users')
          .doc(userUid)
          .collection('Notes')
          .doc(doc.id)
          .collection('Events')
          .get();

      final events = eventsSnapshot.docs.map((eventDoc) {
        final data = eventDoc.data();
        return Event(
          title: data['title'],
          description: data['description'],
          date: DateTime.parse(data['date']),
        );
      }).toList();

      fetchedMarkedDays[day] = events;
    }

    setState(() {
      _markedDays = fetchedMarkedDays;
    });
  }

  Future<void> _fetchEvents() async {
    if (_auth.currentUser == null || _selectedDay == null) return;

    final userUid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection('Users')
        .doc(userUid)
        .collection('Notes')
        .doc(_selectedDay!.toIso8601String())
        .collection('Events')
        .get();

    setState(() {
      _selectedEvents = snapshot.docs.map((doc) {
        final data = doc.data();
        return Event(
          title: data['title'],
          description: data['description'],
          date: DateTime.parse(data['date']),
        );
      }).toList();
    });
  }

  Future<void> _addEventToFirestore(String title, String? description) async {
    if (_auth.currentUser == null || _selectedDay == null) return;

    final userUid = _auth.currentUser!.uid;
    final event = Event(
      title: title,
      description: description,
      date: _selectedDay!,
    );

    final eventRef = _firestore
        .collection('Users')
        .doc(userUid)
        .collection('Notes')
        .doc(_selectedDay!.toIso8601String())
        .collection('Events')
        .doc();

    await eventRef.set(event.toJson());
    await _fetchEvents();
    await _fetchMonthEvents(_focusedDay); // Ayın işaretli günlerini güncelle
  }

  void _addEvent() {
    if (_selectedDay == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController titleController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Yeni Not Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          _addEventToFirestore(
                            titleController.text,
                            descriptionController.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      body: Stack(
        children: [
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchEvents();
                },
                onPageChanged: (focusedDay) {
                  _fetchMonthEvents(focusedDay);
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: const TextStyle(color: Colors.white70),
                  markerDecoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white70),
                  weekendStyle: TextStyle(color: Colors.white70),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (_markedDays.keys.contains(date)) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  selectedBuilder: (context, date, _) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                  todayBuilder: (context, date, _) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    return ListTile(
                      title: Text(
                        event.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        event.description ?? 'Açıklama yok',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _addEvent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Ekle', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
