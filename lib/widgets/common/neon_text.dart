import 'package:flutter/material.dart';

class NeonText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final double blurRadius;
  final TextAlign? textAlign;

  const NeonText({
    super.key,
    required this.text,
    required this.style,
    this.glowColor = const Color(0xFF00E5FF),
    this.blurRadius = 12.0,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style.copyWith(
        shadows: [
          Shadow(
            color: glowColor.withValues(alpha: 0.8),
            blurRadius: blurRadius,
          ),
          Shadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: blurRadius * 2,
          ),
        ],
      ),
    );
  }
}
