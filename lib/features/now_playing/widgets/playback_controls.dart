import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';

class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool isBuffering;
  final LoopMode loopMode;
  final bool shuffleEnabled;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleLoop;
  final VoidCallback onToggleShuffle;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    this.isBuffering = false,
    required this.loopMode,
    required this.shuffleEnabled,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleLoop,
    required this.onToggleShuffle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.cyan : AppColors.lavender;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: shuffleEnabled ? activeColor : inactiveColor,
              size: 20,
            ),
            onPressed: onToggleShuffle,
          ),

          // Previous
          _buildCircleButton(
            icon: Icons.skip_previous_rounded,
            size: 50,
            iconSize: 28,
            isDark: isDark,
            onTap: onPrevious,
          ),

          // Play/Pause
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6C4AB6),
                    Color(0xFF4C308A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lavender.withAlpha(60),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withAlpha(30),
                  width: 1,
                ),
              ),
              child: isBuffering
                  ? const Padding(
                      padding: EdgeInsets.all(22.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
          ),

          // Next
          _buildCircleButton(
            icon: Icons.skip_next_rounded,
            size: 50,
            iconSize: 28,
            isDark: isDark,
            onTap: onNext,
          ),

          // Repeat
          IconButton(
            icon: Icon(
              _getRepeatIcon(),
              color: loopMode != LoopMode.off ? activeColor : inactiveColor,
              size: 20,
            ),
            onPressed: onToggleLoop,
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  IconData _getRepeatIcon() {
    switch (loopMode) {
      case LoopMode.off:
        return Icons.repeat;
      case LoopMode.all:
        return Icons.repeat;
      case LoopMode.one:
        return Icons.repeat_one;
    }
  }
}
