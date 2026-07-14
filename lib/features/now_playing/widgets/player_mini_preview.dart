import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../data/models/song_model.dart';

/// Floating frosted glass preview panel shown at the top of the now playing screen
class PlayerMiniPreview extends StatelessWidget {
  final SongModel song;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PlayerMiniPreview({
    super.key,
    required this.song,
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.isBuffering = false,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        height: 160,
        borderRadius: 24,
        blur: 30,
        opacity: 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Section (Text)
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress Bar Mini
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextSecondary.withAlpha(40)
                        : AppColors.lightTextSecondary.withAlpha(40),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 3,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Positioned(
                      left: (constraints.maxWidth * progress).clamp(
                          0.0,
                          constraints.maxWidth > 8 ? constraints.maxWidth - 8 : 0.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const Spacer(),
            
            // Controls Mini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add Song Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Add Song',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.add_circle_outline,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ],
                  ),
                ),
                
                // Playback controls
                Row(
                  children: [
                    _buildMiniControl(
                      icon: Icons.skip_previous_rounded,
                      onTap: onPrevious,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildMiniControl(
                      icon: isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onTap: onPlayPause,
                      isDark: isDark,
                      isPlayButton: true,
                    ),
                    const SizedBox(width: 12),
                    _buildMiniControl(
                      icon: Icons.skip_next_rounded,
                      onTap: onNext,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniControl({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isPlayButton = false,
  }) {
    return GestureDetector(
      onTap: (isPlayButton && isBuffering) ? null : onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlayButton
              ? (isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10))
              : Colors.transparent,
          border: isPlayButton
              ? Border.all(
                  color: isDark ? Colors.white24 : Colors.black12, width: 1)
              : null,
        ),
        child: (isPlayButton && isBuffering)
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              )
            : Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
      ),
    );
  }
}
