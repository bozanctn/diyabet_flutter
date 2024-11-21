class Event {
  final String title;
  final DateTime date;
  final String? description; // Yeni: Açıklama

  Event({required this.title, required this.date, this.description});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'description': description, // Yeni: Açıklama
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      description: json['description'], // Yeni: Açıklama
    );
  }
}
