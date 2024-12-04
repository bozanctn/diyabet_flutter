class Event {
  final String title;
  final DateTime date;
  final String? description;
  final String? documentId; // Yeni: Document ID

  Event({
    required this.title,
    required this.date,
    this.description,
    this.documentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return Event(
      title: json['title'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      documentId: documentId,
    );
  }
}
