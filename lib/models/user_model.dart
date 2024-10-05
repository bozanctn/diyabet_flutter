import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String surname;
  final DateTime birthdate;
  final String gender;
  final String weight;
  final String height;
  final bool first;
  final String profileImageUrl;
  final String email;

  UserProfile({
    required this.uid,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.gender,
    required this.weight,
    required this.height,
    required this.first,
    required this.profileImageUrl,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'birthdate': birthdate,
      'gender': gender,
      'weight': weight,
      'height': height,
      'first': first,
      'profileImageUrl': profileImageUrl,
      'email': email,
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '', // Boş ise boş string döndür
      name: map['name'] ?? 'Bilinmiyor', // Boş ise varsayılan değer
      surname: map['surname'] ?? 'Bilinmiyor',
      birthdate: map['birthdate'] != null
          ? (map['birthdate'] as Timestamp).toDate()
          : DateTime(2000, 1, 1), // Varsayılan bir tarih ata
      gender: map['gender'] ?? 'Belirtilmemiş', // Varsayılan cinsiyet
      weight: map['weight'] ?? '0', // Boş ise '0' ata
      height: map['height'] ?? '0',
      first: map['first'] ?? false,
      profileImageUrl: map['profileImageUrl'] ?? 'https://via.placeholder.com/150', // Varsayılan resim
      email: map['email'] ?? 'Email Bulunamadı',
    );
  }

  static Future<void> saveProfile(UserProfile profile) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(profile.uid)
        .set(profile.toMap());
  }

  static Future<UserProfile?> getProfile(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Firebase Hatası: $e"); // Hata durumunda konsola yazdır
    }
    return null;
  }
}
