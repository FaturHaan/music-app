import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/player_provider.dart';
import '../../library/widgets/song_tile.dart';

class QueueBottomSheet extends StatelessWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Up Next',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<PlayerProvider>(
              builder: (context, player, _) {
                final queue = player.queue;
                if (queue.isEmpty) {
                  return const Center(child: Text('Queue is empty'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    final isPlaying = player.currentSong?.id == song.id && player.currentSong?.title == song.title;
                    
                    return Container(
                      color: isPlaying ? (isDark ? Colors.white10 : Colors.black12) : Colors.transparent,
                      child: SongTile(
                        song: song,
                        showPosition: true,
                        position: index + 1,
                        onTap: () {
                          // We can just play it directly
                          player.playSong(song, queue);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
