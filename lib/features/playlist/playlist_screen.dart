import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/utils/formatters.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import 'playlist_detail_screen.dart';
import 'create_playlist_dialog.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Playlists'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        body: Consumer<PlaylistProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const LoadingWidget(message: 'Loading playlists...');
            }

            if (provider.playlists.isEmpty) {
              return EmptyState(
                icon: Icons.queue_music,
                title: 'No playlists yet',
                subtitle: 'Create a playlist to organize your music',
                actionLabel: 'Create Playlist',
                onAction: () => _showCreateDialog(context),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = provider.playlists[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PlaylistDetailScreen(playlistId: playlist.id!),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDark
                          ? AppColors.darkCard.withAlpha(120)
                          : AppColors.lightCard.withAlpha(180),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepPurple.withAlpha(isDark ? 40 : 20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              playlist.coverArtPath != null
                                  ? Image.file(
                                      File(playlist.coverArtPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildPlaylistIcon(),
                                    )
                                  : _buildPlaylistIcon(),
                              // Play overlay
                              if (playlist.songs.isNotEmpty)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<PlayerProvider>().playSong(
                                            playlist.songs.first,
                                            playlist.songs,
                                          );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.primaryGradient,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.deepPurple
                                                .withAlpha(80),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Formatters.formatSongCount(playlist.songCount),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaylistIcon() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C4AB6),
            Color(0xFF2D1B69),
          ],
        ),
      ),
      child: const Icon(
        Icons.queue_music,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreatePlaylistDialog(),
    );
  }
}
