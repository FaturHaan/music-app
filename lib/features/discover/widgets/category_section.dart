import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/song_model.dart';
import '../../../providers/player_provider.dart';
import '../../../core/theme/app_colors.dart';

class CategorySection extends StatelessWidget {
  final List<SongModel> songs;

  const CategorySection({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            clipBehavior: Clip.antiAlias,
            child: song.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: song.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(Icons.music_note),
                    errorWidget: (context, url, error) => const Icon(Icons.music_note),
                  )
                : const Icon(Icons.music_note),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          subtitle: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          trailing: const Icon(Icons.play_circle_outline),
          onTap: () {
            context.read<PlayerProvider>().playSong(song, songs);
          },
        );
      },
    );
  }
}
