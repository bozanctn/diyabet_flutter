import 'package:flutter/material.dart';
import 'package:diyabet/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:diyabet/screens/tabbar.dart';
import 'package:diyabet/screens/login/login_screen.dart';
import 'package:diyabet/services/auth_manager.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
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
    return FutureBuilder<bool>(
      future: AuthManager().checkIfSignedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data!) {
            return TabBarScreen(); // User is signed in
          } else {
            return LoginScreen(); // User is not signed in
          }
        }
      },
    );
  }
}