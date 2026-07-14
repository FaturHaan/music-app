import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_container.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          title: const Text('Profile'),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                // App Logo / Profile Card
                GlassContainer(
                  borderRadius: 24,
                  blur: 20,
                  opacity: 0.8,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lavender.withAlpha(60),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Music Listener',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined Today',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Appearance Section
                _buildSectionHeader(context, 'Appearance'),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildSwitchTile(
                    context,
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    value: settings.isDarkMode,
                    onChanged: (_) => settings.toggleTheme(),
                  ),
                ),

                const SizedBox(height: 24),

                // About Section
                _buildSectionHeader(context, 'About'),
                const SizedBox(height: 8),
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        context,
                        icon: Icons.info_outline,
                        title: 'App Version',
                        subtitle: AppConstants.appVersion,
                      ),
                      Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.black12,
                          indent: 16,
                          endIndent: 16),
                      _buildInfoTile(
                        context,
                        icon: Icons.code,
                        title: 'Built with',
                        subtitle: 'Flutter + Dart',
                      ),
                      Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.black12,
                          indent: 16,
                          endIndent: 16),
                      _buildInfoTile(
                        context,
                        icon: Icons.music_note,
                        title: AppConstants.appName,
                        subtitle: 'A beautiful music player',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 120),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cyan
              : AppColors.lavender,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.cyan : AppColors.lavender;
    final textPrim = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primary.withAlpha(20),
        ),
        child: Icon(
          icon,
          color: primary,
          size: 22,
        ),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textPrim)),
      subtitle: Text(subtitle, style: TextStyle(color: textSec)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: primary,
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.cyan : AppColors.lavender;
    final textPrim = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSec = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: primary.withAlpha(20),
        ),
        child: Icon(
          icon,
          color: primary,
          size: 22,
        ),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textPrim)),
      subtitle: Text(subtitle, style: TextStyle(color: textSec)),
    );
  }
}
