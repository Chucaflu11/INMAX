import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Usuario no autenticado')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mi Perfil')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child:
                      user.avatar != null
                          ? null // Aquí se cargaría la imagen si existiera
                          : Text(
                            user.handle.isNotEmpty
                                ? user.handle[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 40),
                          ),
                ),
                const SizedBox(height: 24),
                // Nombre de usuario
                Text(
                  user.handle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (user.displayName != null &&
                    user.displayName!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.displayName!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
                const SizedBox(height: 16),
                // Email
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                ),
                // DID
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('DID'),
                    subtitle: Text(user.did),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 24),
                // Botón de editar perfil (aún no implementado)
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edición de perfil no implementada'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
