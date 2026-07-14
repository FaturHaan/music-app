import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/playlist_model.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/library_provider.dart';
import '../library/widgets/song_tile.dart';
import 'rename_playlist_dialog.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  PlaylistModel? _playlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final provider = context.read<PlaylistProvider>();
    final playlist = await provider.getPlaylistById(widget.playlistId);
    setState(() {
      _playlist = playlist;
      _isLoading = false;
    });
  }

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
          title: Text(_playlist?.name ?? 'Playlist'),
          actions: [
            if (_playlist != null && _playlist!.songs.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                onPressed: () {
                  context.read<PlayerProvider>().playSong(
                        _playlist!.songs.first,
                        _playlist!.songs,
                      );
                },
                tooltip: 'Play All',
              ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddSongsDialog(context),
              tooltip: 'Add Songs',
            ),
            if (_playlist != null)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename') {
                    await showDialog(
                      context: context,
                      builder: (_) => RenamePlaylistDialog(playlist: _playlist!),
                    );
                    _loadPlaylist();
                  } else if (value == 'delete') {
                    _showDeletePlaylistDialog();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text('Rename Playlist'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Playlist', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
        body: _isLoading
            ? const LoadingWidget()
            : _playlist == null
                ? Center(
                    child: Text(
                      'Playlist not found',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  )
                : _playlist!.songs.isEmpty
                    ? EmptyState(
                        icon: Icons.music_off,
                        title: 'No songs in this playlist',
                        subtitle: 'Add songs from your library',
                        actionLabel: 'Add Songs',
                        onAction: () => _showAddSongsDialog(context),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 120),
                        itemCount: _playlist!.songs.length,
                        onReorderItem: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final song = _playlist!.songs.removeAt(oldIndex);
                            _playlist!.songs.insert(newIndex, song);
                          });
                        },
                        itemBuilder: (context, index) {
                          final song = _playlist!.songs[index];
                          return SongTile(
                            key: ValueKey(song.id),
                            song: song,
                            showPosition: true,
                            position: index + 1,
                            onTap: () {
                              context.read<PlayerProvider>().playSong(
                                    song,
                                    _playlist!.songs,
                                  );
                            },
                            onDelete: () async {
                              await context
                                  .read<PlaylistProvider>()
                                  .removeSongFromPlaylist(
                                    widget.playlistId,
                                    song.id!,
                                  );
                              _loadPlaylist();
                            },
                          );
                        },
                      ),
      ),
    );
  }

  void _showDeletePlaylistDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Playlist'),
        content: const Text('Are you sure you want to delete this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistProvider>().deletePlaylist(widget.playlistId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddSongsDialog(BuildContext context) {
    final library = context.read<LibraryProvider>();
    final existingSongIds =
        _playlist?.songs.map((s) => s.id).toSet() ?? <int?>{};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) {
            final availableSongs = library.songs
                .where((s) => !existingSongIds.contains(s.id))
                .toList();

            return GlassContainer(
              borderRadius: 30,
              opacity: 0.9,
              blur: 30,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkTextSecondary.withAlpha(50)
                                : AppColors.lightTextSecondary.withAlpha(50),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Add Songs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  if (availableSongs.isEmpty)
                    const Expanded(
                      child: EmptyState(
                        icon: Icons.music_off,
                        title: 'No songs available',
                        subtitle: 'All songs are already in this playlist',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: availableSongs.length,
                        itemBuilder: (_, index) {
                          final song = availableSongs[index];
                          return ListTile(
                            leading: Icon(
                              Icons.add_circle_outline,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            subtitle: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            onTap: () async {
                              await context
                                  .read<PlaylistProvider>()
                                  .addSongToPlaylist(
                                    widget.playlistId,
                                    song.id!,
                                  );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                _loadPlaylist();
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
