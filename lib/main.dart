import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(INMAXApp());
}

class INMAXApp extends StatelessWidget {
  const INMAXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INMAX',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(),
    );
  }
}
