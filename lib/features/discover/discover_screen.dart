import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/discovery_provider.dart';
import 'widgets/genre_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().loadGenres();
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
          title: const Text('Discover'),
        ),
        body: Consumer<DiscoveryProvider>(
          builder: (context, provider, _) {
            if (provider.error != null) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Oops',
                subtitle: provider.error!,
                actionLabel: 'Retry',
                onAction: () => provider.loadDiscoverData(),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadDiscoverData(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  const SizedBox(height: 16),

                  // Genres Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Browse Genres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: provider.genres.length,
                      itemBuilder: (context, index) {
                        final genre = provider.genres[index];
                        return GenreCard(
                          title: genre.name,
                          color1: Color(genre.color1),
                          color2: Color(genre.color2),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
