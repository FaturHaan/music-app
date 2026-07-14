import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/glass_container.dart';
import 'service_locator.dart';
import 'providers/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/connectivity_provider.dart';
import 'features/library/library_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/playlist/playlist_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'providers/discovery_provider.dart';
import 'mini_player.dart';
import 'features/onboarding/onboarding_screen.dart';

class MusicApp extends StatefulWidget {
  final bool hasSeenOnboarding;

  const MusicApp({super.key, required this.hasSeenOnboarding});

  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _showOnboarding = !widget.hasSeenOnboarding;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<PlayerProvider>()),
        ChangeNotifierProvider.value(value: getIt<LibraryProvider>()),
        ChangeNotifierProvider.value(value: getIt<PlaylistProvider>()),
        ChangeNotifierProvider.value(value: getIt<SearchProvider>()),
        ChangeNotifierProvider.value(value: getIt<DiscoveryProvider>()),
        ChangeNotifierProvider.value(value: getIt<SettingsProvider>()),
        ChangeNotifierProvider.value(value: getIt<ConnectivityProvider>()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Music App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: _showOnboarding
                ? OnboardingScreen(
                    onFinish: () {
                      setState(() {
                        _showOnboarding = false;
                      });
                    },
                  )
                : const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 5 tabs: Explore, Discover, Search, History, Profile
  final List<Widget> _screens = const [
    LibraryScreen(),    // Explore / Home dashboard
    DiscoverScreen(),   // Discover / Trending
    SearchScreen(),     // Search
    PlaylistScreen(),   // History / Playlists
    SettingsScreen(),   // Profile / Settings
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final libraryProvider = context.read<LibraryProvider>();
    final playlistProvider = context.read<PlaylistProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await settingsProvider.loadSettings();
    await libraryProvider.loadSongs();
    await playlistProvider.loadPlaylists();
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
        body: Column(
          children: [
            Consumer<ConnectivityProvider>(
              builder: (context, connectivity, child) {
                if (!connectivity.isOffline) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  color: AppColors.error,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 4,
                    bottom: 4,
                  ),
                  child: const Text(
                    'No internet connection. Showing offline library.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini Player
            Consumer<PlayerProvider>(
              builder: (context, player, _) {
                if (!player.hasCurrentSong) return const SizedBox.shrink();
                return const MiniPlayer();
              },
            ),
            // Glassmorphism Bottom Navigation
            _buildBottomNav(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return GlassContainer(
      borderRadius: 0,
      blur: 30,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Explore',
              isDark: isDark,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome,
              label: 'Discover',
              isDark: isDark,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: 'Search',
              isDark: isDark,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.library_books_outlined,
              activeIcon: Icons.library_books,
              label: 'History',
              isDark: isDark,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;
    final activeColor = isDark ? AppColors.cyan : AppColors.lavender;
    final inactiveColor =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active glow dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? activeColor : Colors.transparent,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: activeColor.withAlpha(120),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
            // Icon
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
