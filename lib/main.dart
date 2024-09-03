import 'package:diyabet/screens/login/profile_info.dart';
import 'package:flutter/material.dart';
import 'package:diyabet/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diyabet/screens/tabbar.dart';
import 'package:diyabet/screens/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = const AndroidInitializationSettings(
      'app_icon');
  var initializationSettingsIOS = const DarwinInitializationSettings();

  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diyabet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black.withOpacity(0.9), // Default color for AppBar
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
          iconTheme: const IconThemeData(
            color: Colors.white, // Color for the back button
          ),
        ),
      ),
      home: AuthWrapper(), // Start with AuthWrapper
      debugShowCheckedModeBanner: false, // This removes the debug banner
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    bool isFirst = snapshot.data!['first'] ?? true;
                    if (isFirst) {
                      return ProfileSetupScreen(); // User's first login
                    } else {
                      return TabBarScreen(); // User has logged in before
                    }
                  } else {
                    return LoginScreen(); // Document doesn't exist, should not happen
                  }
                }
              },
            );
          } else {
            return LoginScreen(); // User not signed in
          }
        }
      },
    );
  }
}
