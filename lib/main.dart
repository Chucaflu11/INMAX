import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'generated/l10n.dart';
import 'locale_provider.dart';

import 'providers/music_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/faq_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // soporte de idioma
      ],
      child: INMAXApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class INMAXApp extends StatelessWidget {
  final bool isLoggedIn;

  const INMAXApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return MaterialApp(
          title: 'INMAX',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: themeProvider.currentTheme,
          theme: ThemeData.light().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20),
            ),
            textTheme: ThemeData.light().textTheme.copyWith(
              bodySmall: const TextStyle(color: Colors.black54),
            ),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          darkTheme: ThemeData.dark().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white70),
              titleTextStyle: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            textTheme: ThemeData.dark().textTheme.copyWith(
              bodySmall: const TextStyle(color: Colors.white70),
            ),
            iconTheme: const IconThemeData(color: Colors.white70),
          ),
          home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
          routes: {
            '/settings': (_) => const SettingsScreen(),
            '/perfil': (_) => const ProfileScreen(),
            '/cambiar-contrasena': (_) => const ChangePasswordScreen(),
            '/faq': (_) => const FaqScreen(),
            '/login': (_) => const LoginScreen(),
          },
        );
      },
    );
  }
}
