import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';

class ProgressSlider extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = duration.inMilliseconds.toDouble();
    final currentValue = position.inMilliseconds.toDouble().clamp(0.0, maxValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Slider with glowing playhead
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: Colors.transparent,
            overlayColor: Colors.transparent,
            trackHeight: 3,
            trackShape: _CustomTrackShape(),
            thumbShape: _GlowingThumbShape(
              glowColor: AppColors.cyan.withAlpha(150),
              innerColor: Colors.white,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(10),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              // Active track gradient
              LayoutBuilder(
                builder: (context, constraints) {
                  final progress = maxValue > 0 ? currentValue / maxValue : 0.0;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: AppColors.cyanGlowGradient,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  );
                },
              ),
              // The actual invisible slider to capture gestures
              Slider(
                value: maxValue > 0 ? currentValue : 0.0,
                min: 0.0,
                max: maxValue > 0 ? maxValue : 1.0,
                onChanged: (value) {
                  onSeek(Duration(milliseconds: value.round()));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Timestamps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Formatters.formatDuration(position.inMilliseconds),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              Formatters.formatDuration(duration.inMilliseconds),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 2;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class _GlowingThumbShape extends SliderComponentShape {
  final Color glowColor;
  final Color innerColor;
  final double radius = 6.0;

  _GlowingThumbShape({
    required this.glowColor,
    required this.innerColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius * 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw glow
    final paintGlow = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 2, paintGlow);

    // Draw inner thumb
    final paintInner = Paint()..color = innerColor;
    canvas.drawCircle(center, radius, paintInner);
  }
}
