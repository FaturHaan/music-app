import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

/// Cover art displayed as a large rounded rectangle on the now playing screen.
class PlayerCoverArt extends StatelessWidget {
  final String? coverArtPath;
  final Object heroTag;

  const PlayerCoverArt({
    super.key,
    this.coverArtPath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final size = screenWidth * 0.55;

    return Hero(
      tag: 'cover_$heroTag',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient:
              coverArtPath == null ? AppColors.primaryGradient : null,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.deepPurple : AppColors.lavender)
                  .withAlpha(80),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: AppColors.magenta.withAlpha(20),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: coverArtPath != null
            ? (coverArtPath!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: coverArtPath!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildDefaultCover(),
                    errorWidget: (_, __, ___) => _buildDefaultCover(),
                  )
                : Image.file(
                    File(coverArtPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultCover(),
                  ))
            : _buildDefaultCover(),
      ),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            color: Colors.white.withAlpha(180),
            size: 64,
          ),
          const SizedBox(height: 8),
          Text(
            'NEW MUSIC',
            style: TextStyle(
              color: Colors.white.withAlpha(120),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
