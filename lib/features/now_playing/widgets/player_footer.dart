import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/player_provider.dart';
import 'lyrics_bottom_sheet.dart';
import 'queue_bottom_sheet.dart';

class PlayerFooter extends StatelessWidget {
  const PlayerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lyrics icon
          IconButton(
            icon: Icon(
              Icons.lyrics_outlined,
              color: color,
              size: 24,
            ),
            onPressed: () {
              final playerProvider = context.read<PlayerProvider>();
              final currentSong = playerProvider.currentSong;
              if (currentSong != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: LyricsBottomSheet(song: currentSong),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No song is currently playing')),
                );
              }
            },
          ),
          
          // Device Audio Info
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speaker_group_outlined,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Phone Speaker',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          // Playlist Icon
          IconButton(
            icon: Icon(
              Icons.queue_music,
              color: color,
              size: 24,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const QueueBottomSheet(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
