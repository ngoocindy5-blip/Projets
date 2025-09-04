import 'package:bus_easy/screen/User%20screen/Home/Home_page.dart';

import 'package:bus_easy/screen/User%20screen/landing/landing_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GlobalVoyagesApp());
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
      home: LandingPage(),
    );
  }
}

