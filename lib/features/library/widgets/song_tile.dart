import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/song_model.dart';
import 'source_badge.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final bool showPosition;
  final int? position;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
    this.showPosition = false,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(song.id ?? song.sourceId ?? song.title),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.error.withAlpha(30),
        ),
        child: const Icon(Icons.delete, color: AppColors.error),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? AppColors.darkCard.withAlpha(120)
                : AppColors.lightCard.withAlpha(180),
          ),
          child: Row(
            children: [
              if (showPosition && position != null) ...[
                SizedBox(
                  width: 28,
                  child: Text(
                    '$position',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Cover Art with play overlay
              Stack(
                children: [
                  Hero(
                    tag: 'cover_${song.id ?? song.sourceId ?? song.title}',
                    child: Container(
                      width: 50,
                      height: 50,
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
                  ),
                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withAlpha(40),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (song.isOnline) ...[
                          const SizedBox(width: 6),
                          SourceBadge(source: song.source),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${song.artist} • ${Formatters.formatDuration(song.durationMs)}',
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

              // Three-dot menu (replaces favorite icon inline)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? AppColors.darkElevated : AppColors.lightElevated,
                onSelected: (value) {
                  if (value == 'favorite') {
                    onFavoriteToggle?.call();
                  } else if (value == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (onFavoriteToggle != null)
                    PopupMenuItem(
                      value: 'favorite',
                      child: Row(
                        children: [
                          Icon(
                            song.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: song.isFavorite
                                ? AppColors.favorite
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(song.isFavorite
                              ? 'Remove Favorite'
                              : 'Add to Favorite'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
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
        size: 24,
      ),
    );
  }
}
