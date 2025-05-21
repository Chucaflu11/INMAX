import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/svg_icons.dart';
import '../constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: SvgIcons.home, label: 'Home'),
      _NavItem(icon: SvgIcons.feed, label: 'Feed'),
      _NavItem(icon: SvgIcons.create, label: 'Create'),
      _NavItem(icon: SvgIcons.music, label: 'Music'),
      _NavItem(icon: SvgIcons.profile, label: 'Profile'),
    ];

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.footerDark,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemTapped(index),
            behavior: HitTestBehavior.translucent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  item.icon,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.white : AppColors.lightGrey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}
