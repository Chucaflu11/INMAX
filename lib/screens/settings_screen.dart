import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../locale_provider.dart';
import 'package:inmax/generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? true;
    });
  }

  Future<void> _togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    setState(() {
      pushNotifications = value;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: const Text("¿Estás seguro que quieres cerrar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Español"),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('es'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          _buildSectionTitle(s.profile, theme),
          _buildSettingsTile(
            icon: Icons.person,
            title: s.profile,
            onTap: () => Navigator.pushNamed(context, '/perfil'),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: s.changePassword,
            onTap: () => Navigator.pushNamed(context, '/cambiar-contrasena'),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: s.logout,
            onTap: _logout,
            theme: theme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Preferencias', theme),
          _buildSettingsTile(
            icon: Icons.brightness_6,
            title: s.darkMode,
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                );
              },
            ),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: s.language,
            onTap: _showLanguageDialog,
            theme: theme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle(s.pushNotifications, theme),
          _buildSettingsTile(
            icon: Icons.notifications_active_outlined,
            title: s.pushNotifications,
            trailing: Switch(
              value: pushNotifications,
              onChanged: _togglePushNotifications,
            ),
            theme: theme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Privacidad y seguridad', theme),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: s.terms,
            onTap: () => _showInfoDialog(s.terms, 'Aquí irán los términos...'),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: Icons.policy_outlined,
            title: s.privacyPolicy,
            onTap: () => _showInfoDialog(s.privacyPolicy, 'Aquí irá la política...'),
            theme: theme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Soporte', theme),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: s.faq,
            onTap: () => Navigator.pushNamed(context, '/faq'),
            theme: theme,
          ),
          _buildSettingsTile(
            icon: Icons.mail_outline,
            title: s.contact,
            onTap: () => _showInfoDialog(s.contact, 'Correo: soporte@tuapp.com'),
            theme: theme,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Acerca de la app', theme),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: s.version,
            trailing: const Text('v1.0.0'),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required ThemeData theme,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      horizontalTitleGap: 16,
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ),
    );
  }
}
