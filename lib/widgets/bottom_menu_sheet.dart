import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/svg_icons.dart';
import '../constants/app_colors.dart';

class BottomMenuSheet extends StatefulWidget {
  const BottomMenuSheet({super.key});

  @override
  State<BottomMenuSheet> createState() => _BottomMenuSheetState();
}

class _BottomMenuSheetState extends State<BottomMenuSheet> {
  String selectedOption = 'Stage';

  final List<_MenuItem> menuItems = [
    _MenuItem('Stage', SvgIcons.stage),
    _MenuItem('Ads', SvgIcons.ads),
    _MenuItem('Pings', SvgIcons.pings),
    _MenuItem('Discover', SvgIcons.discover),
    _MenuItem('Admin', SvgIcons.admin),
    _MenuItem('Settings', SvgIcons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: menuItems.map((item) {
          final isSelected = item.title == selectedOption;
          return ListTile(
            leading: SvgPicture.asset(
              item.iconPath,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.pink : Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.pink : Colors.black87,
              ),
            ),
            onTap: () {
              setState(() {
                selectedOption = item.title;
              });
              Navigator.of(context).pop(); // Puedes comentar esto si no quieres cerrar al seleccionar
              // Aquí puedes añadir navegación lógica
            },
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String iconPath;
  _MenuItem(this.title, this.iconPath);
}
