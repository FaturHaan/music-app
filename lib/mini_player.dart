import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'core/theme/app_colors.dart';
import 'providers/player_provider.dart';
import 'features/now_playing/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PlayerProvider>(
      builder: (context, player, _) {
        final song = player.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const NowPlayingScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 350),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.glassGradientDark
                        : AppColors.glassGradientLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? AppColors.glassDarkBorder
                          : AppColors.glassLightBorder,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // Cover Art
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: song.bestCoverArt == null
                                ? AppColors.primaryGradient
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepPurple.withAlpha(40),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: song.bestCoverArt != null
                              ? (song.bestCoverArt!.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: song.bestCoverArt!,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => _buildDefaultCover(),
                                      errorWidget: (_, __, ___) => _buildDefaultCover(),
                                    )
                                  : Image.file(
                                      File(song.bestCoverArt!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildDefaultCover(),
                                    ))
                              : _buildDefaultCover(),
                        ),
                        const SizedBox(width: 12),
                        // Song Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        // Controls
                        _buildControlButton(
                          icon: Icons.skip_previous_rounded,
                          size: 24,
                          isDark: isDark,
                          onTap: () => player.previous(),
                        ),
                        const SizedBox(width: 2),
                        // Play/Pause — highlighted
                        GestureDetector(
                          onTap: player.isBuffering ? null : () => player.togglePlayPause(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.lavender.withAlpha(60),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: player.isBuffering
                                ? const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    player.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        _buildControlButton(
                          icon: Icons.skip_next_rounded,
                          size: 24,
                          isDark: isDark,
                          onTap: () => player.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: size,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}
