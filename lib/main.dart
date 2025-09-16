import 'package:bus_easy/screen/admin/home/dashboard_admin.dart';
import 'package:bus_easy/screen/admin/login.dart';
import 'package:bus_easy/screen/user_screen/auth/login.dart';
import 'package:bus_easy/screen/user_screen/landing/landing_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const GlobalVoyagesApp());
}

class GlobalVoyagesApp extends StatelessWidget {
  const GlobalVoyagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLOBAL VOYAGES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21C17A)),
        fontFamily: 'Roboto',
      ),

      home: kIsWeb ? const AdminLoginPage() : const LandingPage(),
    );
  }
}
