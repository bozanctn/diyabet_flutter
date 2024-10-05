import 'package:cloud_firestore/cloud_firestore.dart';

class MedModel {
  String uid;
  String name;
  String med1;
  String med2;
  String? med3;
  String? med4;
  String? med5;
  DateTime timestamp;

  MedModel({
    required this.uid,
    required this.name,
    required this.med1,
    required this.med2,
    this.med3,
    this.med4,
    this.med5,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'med1': med1,
      'med2': med2,
      'med3': med3 ?? '',
      'med4': med4 ?? '',
      'med5': med5 ?? '',
      'timestamp': timestamp.toIso8601String(), // Zaman bilgisini ekleyelim
    };
  }

  factory MedModel.fromMap(Map<String, dynamic> map) {
    return MedModel(
      uid: map['uid'],
      name: map['name'],
      med1: map['med1'],
      med2: map['med2'],
      med3: map['med3'],
      med4: map['med4'],
      med5: map['med5'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  static Future<void> saveProfile(MedModel medModel) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(medModel.uid)
        .collection('Medicine') // Kullanıcıya özel Medicine alt koleksiyonu
        .add(medModel.toMap());
  }

  static Future<List<MedModel>> getMedications(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Medicine')
        .orderBy('timestamp', descending: true) // Zaman bilgisine göre sıralama
        .get();
    return querySnapshot.docs.map((doc) => MedModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
