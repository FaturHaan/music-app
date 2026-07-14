import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/song_model.dart';
import '../../../../data/services/lyrics_service.dart';

class LyricsBottomSheet extends StatefulWidget {
  final SongModel song;

  const LyricsBottomSheet({super.key, required this.song});

  @override
  State<LyricsBottomSheet> createState() => _LyricsBottomSheetState();
}

class _LyricsBottomSheetState extends State<LyricsBottomSheet> {
  final LyricsService _lyricsService = LyricsService();
  String? _lyrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  Future<void> _fetchLyrics() async {
    final lyrics = await _lyricsService.getLyrics(widget.song.artist, widget.song.title);
    if (mounted) {
      setState(() {
        _lyrics = lyrics;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lyrics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.song.title} - ${widget.song.artist}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 40),
                    child: Text(
                      _lyrics ?? 'Lyrics not found for this song.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
