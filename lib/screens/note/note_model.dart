// lib/models/note_model.dart
class NoteModel {
  String title;
  String note;
  String date;
  String iconName;
  String documentID;
  String userUID;

  NoteModel({
    required this.title,
    required this.note,
    required this.date,
    required this.iconName,
    required this.documentID,
    required this.userUID,
  });

  // Convert NoteModel instance to Map for database purposes
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'date': date,
      'iconName': iconName,
      'documentID': documentID,
      'userUID': userUID,
    };
  }

  // Factory method to create a NoteModel from a Map
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      title: map['title'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] ?? '',
      iconName: map['iconName'] ?? '',
      documentID: map['documentID'] ?? '',
      userUID: map['userUID'] ?? '',
    );
  }
}
