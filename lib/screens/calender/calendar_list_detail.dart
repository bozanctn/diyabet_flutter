import 'package:flutter/material.dart';
import 'package:diyabet/screens/calender/calendar_event_model.dart';

class CalendarListDetail extends StatelessWidget {
  final Event event;

  const CalendarListDetail({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: const Color.fromRGBO(19, 69, 122, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başlık: ${event.title}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tarih: ${event.date}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (event.description != null)
              Text(
                'Açıklama: ${event.description}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
