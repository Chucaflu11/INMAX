import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/music_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  // Necesario para inicialización asíncrona
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MusicProvider(),
        ),
      ],
      child: const INMAXApp(),
    ),
  );
}

class INMAXApp extends StatefulWidget {
  const INMAXApp({super.key});

  @override
  State<INMAXApp> createState() => _INMAXAppState();
}

class _INMAXAppState extends State<INMAXApp> {
  @override
  void initState() {
    super.initState();
    // Inicializar Spotify después de que el widget se monte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.initializeSpotify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INMAX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          // Mostrar LoginScreen hasta que Spotify esté conectado
          if (!musicProvider.isConnected) {
            return const LoginScreen();
          }
          // Aquí puedes navegar a tu pantalla principal cuando esté conectado
          return const LoginScreen(); // Cambia por tu pantalla principal
        },
      ),
    );
  }
}