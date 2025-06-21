import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [

          // ===== Cuenta =====
          _buildSectionTitle('Cuenta'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Perfil',
            onTap: () {
              // TODO: Navegar a pantalla de perfil
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            onTap: () {
              // TODO: Navegar a pantalla de cambio de contraseña
            },
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            onTap: () {
              // TODO: Lógica de logout
            },
          ),

          const SizedBox(height: 20),

          // ===== Preferencias =====
          _buildSectionTitle('Preferencias'),
          _buildSettingsTile(
            icon: Icons.brightness_6,
            title: 'Modo oscuro',
            trailing: Switch(value: false, onChanged: (val) {
              // TODO: Cambiar tema
            }),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Idioma',
            onTap: () {
              // TODO: Mostrar selector de idioma
            },
          ),

          const SizedBox(height: 20),

          // ===== Notificaciones =====
          _buildSectionTitle('Notificaciones'),
          _buildSettingsTile(
            icon: Icons.notifications_active_outlined,
            title: 'Notificaciones push',
            trailing: Switch(value: true, onChanged: (val) {
              // TODO: Activar/desactivar notificaciones
            }),
          ),

          const SizedBox(height: 20),

          // ===== Seguridad =====
          _buildSectionTitle('Privacidad y seguridad'),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Términos y condiciones',
            onTap: () {
              // TODO: Mostrar términos
            },
          ),
          _buildSettingsTile(
            icon: Icons.policy_outlined,
            title: 'Política de privacidad',
            onTap: () {
              // TODO: Mostrar política
            },
          ),

          const SizedBox(height: 20),

          // ===== Soporte =====
          _buildSectionTitle('Soporte'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Preguntas frecuentes (FAQ)',
            onTap: () {
              // TODO: Navegar a FAQ
            },
          ),
          _buildSettingsTile(
            icon: Icons.mail_outline,
            title: 'Contacto',
            onTap: () {
              // TODO: Mostrar info de contacto
            },
          ),

          const SizedBox(height: 20),

          // ===== Info App =====
          _buildSectionTitle('Acerca de la app'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'Versión',
            trailing: const Text('v1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      horizontalTitleGap: 16,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
