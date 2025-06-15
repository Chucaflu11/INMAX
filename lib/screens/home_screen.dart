import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'stage_screen.dart';
import 'create_screen.dart';
import 'music_screen.dart';
import 'profile_screen.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    _HomeScreenState createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0;

    bool isTablet(BuildContext context) {
      return MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1200;
    }

    bool isDesktop(BuildContext context) {
      return MediaQuery.of(context).size.width >= 1200;
    }

    bool isMobile(BuildContext context) {
      return MediaQuery.of(context).size.width < 600;
    }

    Widget _buildPlayerBar() {
      return LayoutBuilder(
        builder: (context, constraints) {
          final padding = isDesktop(context)
              ? 20.0
              : isTablet(context)
                  ? 16.0
                  : 12.0;
          final titleFontSize = isDesktop(context)
              ? 16.0
              : isTablet(context)
                  ? 15.0
                  : 14.0;
          final subtitleFontSize = isDesktop(context)
              ? 14.0
              : isTablet(context)
                  ? 13.0
                  : 12.0;
          final iconSize = isDesktop(context)
              ? 28.0
              : isTablet(context)
                  ? 26.0
                  : 24.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFFF385D),
                  const Color(0xFF591421),
                ],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Icon(Icons.pause, color: Colors.white, size: iconSize),
                  SizedBox(width: padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Song Name",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Artist Name",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: subtitleFontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: iconSize),
            label: showLabels ? "Inicio" : "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view, size: iconSize),
            label: showLabels ? "Explorar" : "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: iconSize),
            label: showLabels ? "Crear" : "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox, size: iconSize),
            label: showLabels ? "Inbox" : "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: iconSize),
            label: showLabels ? "Perfil" : "",
          ),
        ],
      );
    }

    Widget _buildAppBar() {
      return LayoutBuilder(
        builder: (context, constraints) {
          return AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/icons/inmaxpng.png',
                  height: isDesktop(context)
                      ? 60
                      : isTablet(context)
                          ? 55
                          : 50,
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // No hay acciones por ahora
                  },
                  itemBuilder: (context) => [],
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
          );
        },
      );
    }

    Widget _getBody() {
      switch (_selectedIndex) {
        case 0:
          return FeedScreen();
        case 1:
          return const Center(child: Text('Stage Screen', style: TextStyle(fontSize: 24)));
        case 2:
          return CreateScreen();
        case 3:
          return const Center(child: Text('Music Screen', style: TextStyle(fontSize: 24)));
        case 4:
          return const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24)));
        default:
          return FeedScreen();
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: _buildAppBar(),
        ),
        body: Column(
          children: [
            Expanded(child: _getBody()),
            _buildPlayerBar(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      );
    }
  }