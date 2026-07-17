import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/search_provider.dart';
import '../../providers/player_provider.dart';
import '../library/widgets/song_tile.dart';

import '../../core/constants/app_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedSource = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          title: const Text('Search'),
        ),
        body: Column(
          children: [
            // Glassmorphism Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: GlassContainer(
                height: 60,
                borderRadius: 16,
                blur: 20,
                opacity: 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<SearchProvider>().search(query);
                  },
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, albums...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    suffixIcon: Consumer<SearchProvider>(
                      builder: (context, search, _) {
                        if (!search.hasQuery) return const SizedBox.shrink();
                        return IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            context.read<SearchProvider>().clearSearch();
                          },
                        );
                      },
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ),

            // Source Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSourceChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildSourceChip('Local', AppConstants.sourceLocal),
                  const SizedBox(width: 8),
                  _buildSourceChip('SoundCloud', AppConstants.sourceSoundcloud),
                  const SizedBox(width: 8),
                  _buildSourceChip('iTunes', AppConstants.sourceItunes),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Results
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, search, _) {
                  if (!search.hasQuery) {
                    return const EmptyState(
                      icon: Icons.search,
                      title: 'Search your music',
                      subtitle: 'Find songs by title, artist, or album',
                    );
                  }

                  if (search.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var displayResults = search.results;
                  if (_selectedSource != 'all') {
                    displayResults = displayResults.where((song) => song.source == _selectedSource).toList();
                  }

                  if (displayResults.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No results found',
                      subtitle: 'Try a different search term or source',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: displayResults.length,
                    itemBuilder: (context, index) {
                      final song = displayResults[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          context.read<PlayerProvider>().playSong(
                                song,
                                displayResults,
                              );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceChip(String label, String sourceValue) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedSource == sourceValue,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSource = sourceValue;
          });
        }
      },
      selectedColor: AppColors.lavender.withAlpha(50),
    );
  }
}
