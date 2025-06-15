import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isPrivate = false;
  bool publicStage = true;
  bool followersOnly = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;
    final pink = const Color(0xFFFF385D);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? width * 0.18 : 20,
          vertical: isWide ? 36 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: isWide ? 60 : 48,
              backgroundImage: AssetImage('assets/taxmanMockup.jpg'),
            ),
            SizedBox(height: isWide ? 24 : 16),
            // Nombre y usuario
            Text(
              'Juan Pérez',
              style: TextStyle(
                fontSize: isWide ? 28 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '@juanperez',
              style: TextStyle(
                fontSize: isWide ? 18 : 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isWide ? 18 : 12),
            // Bio
            Text(
              'Músico, productor y amante de la tecnología. Compartiendo mi pasión por la música y el arte.',
              style: TextStyle(
                fontSize: isWide ? 17 : 13,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isWide ? 24 : 16),
            // Seguidores y seguidos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '1,234',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 16,
                      ),
                    ),
                    Text(
                      'Seguidores',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 15 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isWide ? 40 : 24),
                Column(
                  children: [
                    Text(
                      '567',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 16,
                      ),
                    ),
                    Text(
                      'Seguidos',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isWide ? 15 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isWide ? 32 : 20),
            // Toggles
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Private Profile'),
                  value: isPrivate,
                  activeColor: pink,
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[200],
                  onChanged: (val) => setState(() => isPrivate = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Public Stage Content'),
                  value: publicStage,
                  activeColor: pink,
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[200],
                  onChanged: (val) => setState(() => publicStage = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Followers Only'),
                  value: followersOnly,
                  activeColor: pink,
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[200],
                  onChanged: (val) => setState(() => followersOnly = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}