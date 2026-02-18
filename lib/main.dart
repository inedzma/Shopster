import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_apps/screens/homepage_screen.dart';
import 'package:mobile_apps/screens/login_screen.dart';
import 'package:mobile_apps/screens/main_layout.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/homepage_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopster',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Ako Firebase kaže da imamo korisnika, prikaži HomeScreen
          if (snapshot.hasData) {
            return const MainLayout(
              body: HomepageScreen(),
            );
          }
          // U suprotnom, prikaži AuthScreen (Login/Register)
          return const LoginScreen();
        },
      ),
    );
  }
}