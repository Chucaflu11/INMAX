import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/music_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const INMAXApp(),
    ),
  );
}

class INMAXApp extends StatelessWidget {
  const INMAXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INMAX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
