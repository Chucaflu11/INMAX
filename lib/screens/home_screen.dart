import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildCard(String title, String likes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            const Icon(Icons.favorite_border, size: 14, color: Colors.black54),
            const SizedBox(width: 4),
            Text(likes, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerBar() {
    return Container(
      color: Color(0xFFFF385D),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.pause, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Song Name", style: TextStyle(color: Colors.white)),
                Text("Artist Name", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.favorite_border, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFFF385D),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _buildCard("User 1", "43"),
      _buildCard("User 2", "1"),
      _buildCard("User 3", "27"),
      _buildCard("User 4", "0"),
      _buildCard("User 5", "10"),
      _buildCard("User 6", "2"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('../../assets/inmax_logo.svg', height: 50),
            const Spacer(),
            const Icon(Icons.search),
            const SizedBox(width: 30),
            const Icon(Icons.menu),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
                children: items,
              ),
            ),
          ),
          _buildPlayerBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
