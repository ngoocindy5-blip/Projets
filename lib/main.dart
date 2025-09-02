import 'package:bus_easy/User/Home_Page.dart';
import 'package:bus_easy/admin/AdminDashboard.dart';
import 'package:bus_easy/admin/PricingManagementPage.dart';
import 'package:bus_easy/login/AdminLoginPage.dart';
import 'package:bus_easy/login/AdminRegisterPage.dart';
import 'package:bus_easy/login/Login_page.dart' hide RegisterPage, HomePage;
import 'package:bus_easy/User/NotificationsPage.dart';
import 'package:bus_easy/User/PaymentPage.dart';
import 'package:bus_easy/User/ProfilePage.dart';
import 'package:bus_easy/login/Register_page.dart' hide HomePage;
import 'package:bus_easy/User/RouteTrackingPage.dart';
import 'package:bus_easy/User/SearchPage.dart';
import 'package:bus_easy/admin/UserManagementPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:LoginPage(),
    );
  }
}
