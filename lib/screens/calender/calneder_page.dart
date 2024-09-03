import 'dart:convert';

import 'package:diyabet/noti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../../models/event_model.dart';
import '../blood_sugar_showing/blood_sugar_showing_page.dart';
import '../sugar_measurement/sugar_measurement_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadEvents();
    tz.initializeTimeZones();
    Noti.initialize(flutterLocalNotificationsPlugin);
  }

  void _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }


  Future<void> _requestIOSPermissions() async {
    final flutterLocalNotificationsPlugin = _flutterLocalNotificationsPlugin!;

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _loadEvents() async {
    // Fetch events from Firestore and update the local state
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Event')
          .snapshots()
          .listen((snapshot) {
        Map<DateTime, List<Event>> events = {};
        for (var doc in snapshot.docs) {
          Event event = Event.fromJson(doc.data());
          DateTime date = event.date;
          if (events[date] == null) {
            events[date] = [];
          }
          events[date]!.add(event);
        }
        setState(() {
          _events = events;
          if (_selectedDay != null) {
            _selectedEvents = _events[_selectedDay!] ?? [];
          }
        });
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents = _events[selectedDay] ?? [];
    });
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _eventController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Event'),
          content: TextField(
            controller: _eventController,
            decoration: const InputDecoration(hintText: 'Event Title'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_eventController.text.isNotEmpty) {
                  Event newEvent = Event(
                    title: _eventController.text,
                    date: _selectedDay!,
                  );

                  setState(() {
                    if (_events[_selectedDay!] != null) {
                      _events[_selectedDay!]!.add(newEvent);
                    } else {
                      _events[_selectedDay!] = [newEvent];
                    }
                    _selectedEvents = _events[_selectedDay!]!;
                  });

                  // Save event to Firestore
                  await _saveEventToFirestore(newEvent);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEventToFirestore(Event event) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Event')
          .add(event.toJson());
    }
  }


  Future<void> _scheduleDailyNotification(TimeOfDay timeOfDay, String notificationTitle) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = _flutterLocalNotificationsPlugin!;

    final now = DateTime.now();

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    var androidDetails = const AndroidNotificationDetails(
      'daily_notification_channel_id',
      'Daily Notifications',
      channelDescription: 'This channel is for daily notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    var iOSDetails = const DarwinNotificationDetails();

    var notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final delay = scheduledTime.isBefore(now)
        ? scheduledTime.add(const Duration(days: 1)).difference(now)
        : scheduledTime.difference(now);

    await Future.delayed(delay, () async {
      await flutterLocalNotificationsPlugin.show(
        0,
        notificationTitle,
        'Remember to take your medication or report!',
        notificationDetails,
      );
    });
  }

  void _pickTime(String notificationTitle) async {

    await _requestIOSPermissions(); // Request permissions on iOS



    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );



    if (pickedTime != null) {
      // Saat seçildikten sonra bildirimi planlayın
      await _scheduleDailyNotification(pickedTime, notificationTitle);
    }
  }
  Widget _buildDayWidget(BuildContext context, DateTime day, DateTime focusedDay) {
    bool hasEvents = _events[day] != null && _events[day]!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: hasEvents ? Colors.black : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          if (hasEvents)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(19, 69, 122, 1.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: _buildDayWidget,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color.fromRGBO(19, 69, 122, 1.0),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  defaultDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  outsideDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  holidayDecoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                  weekendTextStyle: const TextStyle(color: Colors.black),
                  outsideTextStyle: const TextStyle(color: Colors.grey),
                  holidayTextStyle: const TextStyle(color: Colors.black),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                  titleTextStyle: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.black),
                  weekendStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _addEvent,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          shadowColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Rapor Vakti ve Hatırlatma',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _pickTime('İlaç İğne Hatırlatma'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          shadowColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.medical_services, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'İlaç İğne Hatırlatma',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BloodSugarDataPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          shadowColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.medical_services, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Şeker Ölçüm Girişi',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.chevron_right, color: Colors.black),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedEvents.isNotEmpty) ...[
                        const Text('Events:', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ..._selectedEvents.map((event) => ListTile(
                          title: Text(event.title, style: const TextStyle(color: Colors.white)),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



