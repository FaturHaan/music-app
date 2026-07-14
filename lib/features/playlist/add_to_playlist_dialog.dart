import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/song_model.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../providers/playlist_provider.dart';
import '../../../service_locator.dart';
import 'create_playlist_dialog.dart';

class AddToPlaylistDialog extends StatelessWidget {
  final SongModel song;

  const AddToPlaylistDialog({super.key, required this.song});

  /// If the song doesn't have a database ID (e.g. online song),
  /// persist it to the database first and return the song with its new ID.
  Future<SongModel?> _ensureSongInDb(SongModel song) async {
    if (song.id != null) return song;

    final songRepo = getIt<SongRepository>();

    // Check if this online song is already saved (by sourceId)
    if (song.sourceId != null) {
      final existing = await songRepo.getSongBySourceId(song.sourceId!);
      if (existing != null) return existing;
    }

    // Save the song to the database
    final newId = await songRepo.insertSong(song);
    return song.copyWith(id: newId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to Playlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const CreatePlaylistDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<PlaylistProvider>(
              builder: (context, provider, _) {
                if (provider.playlists.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No playlists yet.')),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = provider.playlists[index];
                      return ListTile(
                        leading: const Icon(Icons.queue_music),
                        title: Text(playlist.name),
                        subtitle: Text('${playlist.songCount} songs'),
                        onTap: () async {
                          // Ensure the song has a database ID
                          final savedSong = await _ensureSongInDb(song);
                          if (savedSong != null && savedSong.id != null) {
                            provider.addSongToPlaylist(playlist.id!, savedSong.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added to ${playlist.name}')),
                              );
                              Navigator.pop(context);
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to save song.')),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
