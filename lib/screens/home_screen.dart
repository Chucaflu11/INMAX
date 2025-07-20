import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'stage_screen.dart';
import 'create_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'ads_screen.dart';
import '../widgets/mini_music_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  Widget _buildBottomNav() {
    final iconSize = isDesktop(context)
        ? 28.0
        : isTablet(context)
            ? 26.0
            : 24.0;
    final showLabels = isTablet(context) || isDesktop(context);

    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1E1E1E),  
      selectedItemColor: const Color(0xFFFF385D), 
      unselectedItemColor: Colors.grey,           
      type: BottomNavigationBarType.fixed,
      selectedFontSize: showLabels ? 12 : 0,
      unselectedFontSize: showLabels ? 10 : 0,
      iconSize: iconSize,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view),
          label: 'Explorar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Crear',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  void _showMenuSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      barrierColor: Colors.black.withOpacity(0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.campaign, color: Theme.of(context).colorScheme.secondary),
                title: const Text('Ads'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdsScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      title: Row(
        children: [
          Image.asset('assets/icons/inmaxpng.png', height: isDesktop(context) ? 60 : isTablet(context) ? 55 : 50),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMenuSheet,
          ),
        ],
      ),
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation,
      automaticallyImplyLeading: false,
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const FeedScreen();
      case 1:
        return const StageScreen();
      case 2:
        return const CreateScreen();
      case 3:
        return const MusicScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const FeedScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildAppBar(),
      ),
      body: Stack(
        children: [
          _getBody(),
          const Positioned(left: 0, right: 0, bottom: 0, child: MiniMusicPlayer()),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}