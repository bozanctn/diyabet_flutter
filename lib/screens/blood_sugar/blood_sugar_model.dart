class BloodSugarModel {
  final String documentID; // Firestore document ID
  final String userUID;
  final String date;
  final String bloodSugar;
  final String insulinUnit;

  BloodSugarModel({
    required this.documentID,
    required this.userUID,
    required this.date,
    required this.bloodSugar,
    required this.insulinUnit,
  });

  factory BloodSugarModel.fromMap(Map<String, dynamic> map, String id) {
    return BloodSugarModel(
      documentID: id, // Document ID from Firestore
      userUID: map['userUID'] as String,
      date: map['date'] as String,
      bloodSugar: map['bloodSugar'] as String,
      insulinUnit: map['insulinUnit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUID': userUID,
      'date': date,
      'bloodSugar': bloodSugar,
      'insulinUnit': insulinUnit,
    };
  }
}
