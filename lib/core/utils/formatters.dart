class Formatters {
  Formatters._();

  /// Format duration in milliseconds to "mm:ss" or "h:mm:ss"
  static String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration from Duration object
  static String formatDurationFromDuration(Duration duration) {
    return formatDuration(duration.inMilliseconds);
  }

  /// Format date to readable string
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format song count text
  static String formatSongCount(int count) {
    if (count == 0) return 'No songs';
    if (count == 1) return '1 song';
    return '$count songs';
  }
}
