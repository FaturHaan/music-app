import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import 'widgets/player_cover_art.dart';
import 'widgets/player_mini_preview.dart';
import 'widgets/playback_controls.dart';
import 'widgets/progress_slider.dart';
import 'widgets/player_footer.dart';
import 'widgets/now_playing_context_menu.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.nowPlayingDarkGradient
              : AppColors.nowPlayingLightGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Consumer<PlayerProvider>(
            builder: (context, player, _) {
              if (player.currentSong == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No song playing',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                );
              }

              final song = player.currentSong!;

              return Stack(
                children: [
                  // ─── Main Content ──────────────────────────────────
                  Column(
                    children: [
                      // Top spacing for the floating panel
                      SizedBox(height: screenHeight * 0.22),

                      // Large Cover Art
                      PlayerCoverArt(
                        coverArtPath: song.bestCoverArt,
                        heroTag: song.id ?? song.sourceId ?? song.title,
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // Song Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song.artist,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Favorite toggle
                            IconButton(
                              icon: Icon(
                                song.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: song.isFavorite
                                    ? AppColors.favorite
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                                size: 28,
                              ),
                              onPressed: () {
                                context
                                    .read<LibraryProvider>()
                                    .toggleFavorite(song);
                              },
                            ),
                            // Context Menu
                            IconButton(
                              icon: Icon(
                                Icons.more_horiz,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                size: 28,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => NowPlayingContextMenu(song: song),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ProgressSlider(
                          position: player.position,
                          duration: player.duration,
                          onSeek: (position) => player.seek(position),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Main Playback Controls
                      PlaybackControls(
                        isPlaying: player.isPlaying,
                        isBuffering: player.isBuffering,
                        loopMode: player.loopMode,
                        shuffleEnabled: player.shuffleEnabled,
                        onPlayPause: () => player.togglePlayPause(),
                        onNext: () => player.next(),
                        onPrevious: () => player.previous(),
                        onToggleLoop: () => player.toggleLoopMode(),
                        onToggleShuffle: () => player.toggleShuffle(),
                      ),

                      const Spacer(),

                      // Footer with device info
                      const PlayerFooter(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),

                  // ─── Floating Top Preview Panel ─────────────────────
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: PlayerMiniPreview(
                      song: song,
                      position: player.position,
                      duration: player.duration,
                      isPlaying: player.isPlaying,
                      isBuffering: player.isBuffering,
                      onPlayPause: () => player.togglePlayPause(),
                      onPrevious: () => player.previous(),
                      onNext: () => player.next(),
                    ),
                  ),

                  // ─── Hidden Back Button ─────────────────────────────
                  // Allow swipe down to dismiss
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 160,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 300) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
