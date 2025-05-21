import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/svg_icons.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mini_player.dart';
import '../widgets/bottom_menu_sheet.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isPlaying = false;
  bool _isFavorite = false;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BottomMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(SvgIcons.logo, height: 28),
                  Row(
                    children: [
                      SvgPicture.asset(SvgIcons.search, height: 20),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: _openBottomSheetMenu,
                        child: SvgPicture.asset(SvgIcons.menu, height: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // MAIN CONTENT
            Expanded(
              child: Center(
                child: Text(
                  'Pantalla ${_selectedIndex + 1}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // MINI PLAYER
            MiniPlayer(
              isPlaying: _isPlaying,
              onTogglePlay: () {
                setState(() => _isPlaying = !_isPlaying);
              },
              isFavorite: _isFavorite,
              onToggleFavorite: () {
                setState(() => _isFavorite = !_isFavorite);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),

      // FOOTER
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavTap,
      ),
    );
  }
}
