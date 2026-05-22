import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'widgets/responsive_guard.dart';
import 'screens/admin/admin_demo_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusPark',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const ResponsiveGuard(child: AdminDemoPage()),
    );
  }
}