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
  String? documentId; // Firestore'daki belge kimliği

  MedModel({
    required this.uid,
    required this.name,
    required this.med1,
    required this.med2,
    this.med3,
    this.med4,
    this.med5,
    required this.timestamp,
    this.documentId, // Opsiyonel, Firestore'dan alınan belgelerde doldurulacak
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
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MedModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return MedModel(
      uid: map['uid'],
      name: map['name'],
      med1: map['med1'],
      med2: map['med2'],
      med3: map['med3'] ?? 'Not yok', // Varsayılan değer
      med4: map['med4'] ?? 'Not yok', // Varsayılan değer
      med5: map['med5'] ?? 'Not yok', // Varsayılan değer
      timestamp: DateTime.parse(map['timestamp']),
      documentId: documentId,
    );
  }


  static Future<void> saveProfile(MedModel medModel) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(medModel.uid)
        .collection('Medicine')
        .add(medModel.toMap());
  }

  static Future<List<MedModel>> getMedications(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Medicine')
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs.map((doc) {
      return MedModel.fromMap(
        doc.data() as Map<String, dynamic>,
        documentId: doc.id, // Belge kimliği atanıyor
      );
    }).toList();
  }

  static Future<void> deleteProfile(String uid, String documentId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Medicine')
        .doc(documentId)
        .delete();
  }
}
