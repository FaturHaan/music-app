import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_widget.dart';
import '../../providers/library_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import 'widgets/song_tile.dart';



class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<LibraryProvider>(
          builder: (context, library, _) {
            if (library.isLoading) {
              return const LoadingWidget(message: 'Loading your library...');
            }

            return CustomScrollView(
              slivers: [
                // ─── Header ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Playlists',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        // Profile icon + Import button
                        Row(
                          children: [
                            Consumer<LibraryProvider>(
                              builder: (context, lib, _) {
                                return GestureDetector(
                                  onTap: lib.isImporting
                                      ? null
                                      : () => lib.importSongs(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? AppColors.darkCard.withAlpha(180)
                                          : AppColors.lightCard.withAlpha(180),
                                    ),
                                    child: lib.isImporting
                                        ? const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.cyan,
                                            ),
                                          )
                                        : Icon(
                                            Icons.add,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary,
                                            size: 22,
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.darkCard.withAlpha(180)
                                    : AppColors.lightCard.withAlpha(180),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Featured Playlists ────────────────────────
                SliverToBoxAdapter(
                  child: _buildFeaturedPlaylists(context, isDark),
                ),

                // ─── Filters & Sorting ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Tracks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All', library.filter == LibraryFilter.all, () {
                                library.setFilter(LibraryFilter.all);
                              }),
                              const SizedBox(width: 8),
                              _buildFilterChip('Favorites', library.filter == LibraryFilter.favorites, () {
                                library.setFilter(LibraryFilter.favorites);
                              }),
                              const SizedBox(width: 16),
                              Container(width: 1, height: 24, color: Colors.grey.withAlpha(50)),
                              const SizedBox(width: 16),
                              _buildSortChip('Date Added', library.sort == LibrarySort.dateAdded, () {
                                library.setSort(LibrarySort.dateAdded);
                              }),
                              const SizedBox(width: 8),
                              _buildSortChip('Title', library.sort == LibrarySort.title, () {
                                library.setSort(LibrarySort.title);
                              }),
                              const SizedBox(width: 8),
                              _buildSortChip('Artist', library.sort == LibrarySort.artist, () {
                                library.setSort(LibrarySort.artist);
                              }),
                              const SizedBox(width: 8),
                              _buildSortChip('Album', library.sort == LibrarySort.album, () {
                                library.setSort(LibrarySort.album);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Song List ─────────────────────────────────
                if (library.songs.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.library_music,
                      title: 'Your library is empty',
                      subtitle: 'Tap + to import music files',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var songs = library.songs;
                          if (library.filter == LibraryFilter.favorites) {
                            songs = library.favoriteSongs;
                          }
                          
                          // Sort
                          songs = List.from(songs);
                          switch (library.sort) {
                            case LibrarySort.dateAdded:
                              songs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
                              break;
                            case LibrarySort.title:
                              songs.sort((a, b) => a.title.compareTo(b.title));
                              break;
                            case LibrarySort.artist:
                              songs.sort((a, b) => a.artist.compareTo(b.artist));
                              break;
                            case LibrarySort.album:
                              songs.sort((a, b) => a.album.compareTo(b.album));
                              break;
                          }

                          if (index >= songs.length) return null;
                          final song = songs[index];
                          return SongTile(
                            song: song,
                            onTap: () {
                              final playerProvider =
                                  context.read<PlayerProvider>();
                              playerProvider.playSong(
                                  song, songs);
                            },
                            onFavoriteToggle: () {
                              context
                                  .read<LibraryProvider>()
                                  .toggleFavorite(song);
                            },
                            onDelete: () {
                              _showDeleteDialog(context, song);
                            },
                          );
                        },
                        childCount: library.filter == LibraryFilter.favorites 
                            ? library.favoriteSongs.length 
                            : library.songs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.lavender.withAlpha(50),
    );
  }

  Widget _buildSortChip(String label, bool isSelected, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      avatar: isSelected ? const Icon(Icons.arrow_drop_down, size: 16) : null,
      onPressed: onTap,
      backgroundColor: isSelected ? AppColors.cyan.withAlpha(50) : null,
    );
  }

  Widget _buildFeaturedPlaylists(BuildContext context, bool isDark) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            children: [
              // New Music Mix card (always shown)
              _buildPlaylistCard(
                context,
                title: 'New Music Mix',
                subtitle: 'MUSIC FOR YOU',
                gradient: AppColors.meshGradient,
                isDark: isDark,
                icon: Icons.play_circle_filled,
                onTap: () {
                  // Play all songs as a mix
                  final library = context.read<LibraryProvider>();
                  if (library.songs.isNotEmpty) {
                    context
                        .read<PlayerProvider>()
                        .playSong(library.songs.first, library.songs);
                  }
                },
              ),
              const SizedBox(width: 14),
              // Favorites Mix card
              _buildPlaylistCard(
                context,
                title: 'Favorites Mix',
                subtitle: 'MUSIC FOR YOU',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D1B69),
                    Color(0xFF3A2080),
                    Color(0xFF1A1060),
                  ],
                ),
                isDark: isDark,
                icon: Icons.favorite,
                onTap: () {
                  final library = context.read<LibraryProvider>();
                  final favs = library.favoriteSongs;
                  if (favs.isNotEmpty) {
                    context.read<PlayerProvider>().playSong(favs.first, favs);
                  }
                },
              ),
              const SizedBox(width: 14),
              // Dynamic playlist cards
              ...provider.playlists.take(3).map((playlist) {
                return Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: _buildPlaylistCard(
                    context,
                    title: playlist.name,
                    subtitle: '${playlist.songCount} songs',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A0A3E),
                        Color(0xFF3A2080),
                      ],
                    ),
                    isDark: isDark,
                    icon: Icons.queue_music,
                    coverPath: playlist.coverArtPath,
                    onTap: () {
                      if (playlist.songs.isNotEmpty) {
                        context.read<PlayerProvider>().playSong(
                              playlist.songs.first,
                              playlist.songs,
                            );
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required bool isDark,
    required IconData icon,
    String? coverPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepPurple.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Cover art or gradient visual
            if (coverPath != null)
              Positioned.fill(
                child: Image.file(
                  File(coverPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            // Abstract mesh overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _MeshPainter(isDark: isDark),
              ),
            ),
            // Content
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(30),
                    ),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(150),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic song) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${song.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LibraryProvider>().deleteSong(song);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for abstract glowing mesh lines on playlist cards
class _MeshPainter extends CustomPainter {
  final bool isDark;

  _MeshPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Glowing blue line
    paint.color = AppColors.accentBlue.withAlpha(40);
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(
        size.width * 0.3, size.height * 0.1,
        size.width * 0.6, size.height * 0.5,
        size.width, size.height * 0.2,
      );
    canvas.drawPath(path1, paint);

    // Glowing purple line
    paint.color = AppColors.lavender.withAlpha(35);
    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(
        size.width * 0.4, size.height * 0.4,
        size.width * 0.7, size.height * 0.8,
        size.width, size.height * 0.5,
      );
    canvas.drawPath(path2, paint);

    // Subtle cyan accent
    paint.color = AppColors.cyan.withAlpha(25);
    paint.strokeWidth = 0.8;
    final path3 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(
        size.width * 0.5, size.height * 0.3,
        size.width * 0.3, size.height * 0.7,
        size.width * 0.8, size.height,
      );
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => false;
}
