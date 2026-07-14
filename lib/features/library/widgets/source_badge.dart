import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class SourceBadge extends StatelessWidget {
  final String source;

  const SourceBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String label;
    IconData icon;

    switch (source) {
      case AppConstants.sourceJamendo:
        bgColor = const Color(0xFFD32F2F); // Red
        label = 'Jamendo';
        icon = Icons.music_video;
        break;
      case AppConstants.sourceItunes:
        bgColor = const Color(0xFF1976D2); // Blue
        label = 'iTunes';
        icon = Icons.library_music;
        break;
      case AppConstants.sourceYoutube:
        bgColor = const Color(0xFFFF0000); // YouTube Red
        label = 'YouTube';
        icon = Icons.play_circle_outline;
        break;
      case AppConstants.sourceLocal:
      default:
        bgColor = AppColors.cyan; // Local
        label = 'Local';
        icon = Icons.sd_storage;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withAlpha(200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
