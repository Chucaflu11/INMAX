import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/svg_icons.dart';
import '../constants/app_colors.dart';
import 'bottom_menu_sheet.dart'; // ← Importamos el nuevo menú desde abajo

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  void _openBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const BottomMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          SvgPicture.asset(
            SvgIcons.logo,
            height: 32,
          ),

          // Search y Menú
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Aquí puedes abrir una función de búsqueda luego
                },
                icon: SvgPicture.asset(
                  SvgIcons.search,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _openBottomMenu(context),
                icon: SvgPicture.asset(
                  SvgIcons.menu,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.black87,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
