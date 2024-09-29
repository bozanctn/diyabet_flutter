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

  UserProfile({
    required this.uid,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.gender,
    required this.weight,
    required this.height,
    required this.first,
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
    };
  }

  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      name: map['name'],
      surname: map['surname'],
      birthdate: (map['birthdate'] as Timestamp).toDate(),
      gender: map['gender'],
      weight: map['weight'],
      height: map['height'],
      first: map['first'],
    );
  }

  static Future<void> saveProfile(UserProfile profile) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(profile.uid)
        .set(profile.toMap());
  }

  static Future<UserProfile?> getProfile(String uid) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
