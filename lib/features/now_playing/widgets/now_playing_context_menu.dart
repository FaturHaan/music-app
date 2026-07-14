import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/song_model.dart';
import '../../../../data/repositories/song_repository.dart';
import '../../../../providers/library_provider.dart';
import '../../../../service_locator.dart';
import '../../playlist/add_to_playlist_dialog.dart';
import 'lyrics_bottom_sheet.dart';
import 'sleep_timer_dialog.dart';

class NowPlayingContextMenu extends StatelessWidget {
  final SongModel song;

  const NowPlayingContextMenu({super.key, required this.song});

  /// Ensure the song has a database ID. If it's an online song without one,
  /// persist it first.
  Future<SongModel?> _ensureSongInDb(SongModel s) async {
    if (s.id != null) return s;

    final songRepo = getIt<SongRepository>();

    if (s.sourceId != null) {
      final existing = await songRepo.getSongBySourceId(s.sourceId!);
      if (existing != null) return existing;
    }

    final newId = await songRepo.insertSong(s);
    return s.copyWith(id: newId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Playlist'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AddToPlaylistDialog(song: song),
              );
            },
          ),
          Consumer<LibraryProvider>(
            builder: (context, library, _) {
              final isFav = song.isFavorite;
              return ListTile(
                leading: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                title: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
                onTap: () async {
                  final savedSong = await _ensureSongInDb(song);
                  if (savedSong != null) {
                    library.toggleFavorite(savedSong);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lyrics_outlined),
            title: const Text('Show Lyrics'),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: LyricsBottomSheet(song: song),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Song Info'),
            onTap: () {
              Navigator.pop(context);
              _showSongInfo(context, song);
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Sleep Timer'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => const SleepTimerDialog(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showSongInfo(BuildContext context, SongModel song) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        title: const Text('Song Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${song.title}'),
            const SizedBox(height: 8),
            Text('Artist: ${song.artist}'),
            const SizedBox(height: 8),
            Text('Source: ${song.source}'),
            const SizedBox(height: 8),
            Text('Duration: ${song.durationMs ~/ 1000} seconds'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
