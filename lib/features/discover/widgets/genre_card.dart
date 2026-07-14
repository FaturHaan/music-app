import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/search_provider.dart';
import '../../search/search_screen.dart';

class GenreCard extends StatelessWidget {
  final String title;
  final Color color1;
  final Color color2;

  const GenreCard({
    super.key,
    required this.title,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SearchProvider>().search(title);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
      },
      child: Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        boxShadow: [
          BoxShadow(
            color: color1.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.music_note,
              size: 80,
              color: Colors.white.withAlpha(50),
            ),
          ),
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
