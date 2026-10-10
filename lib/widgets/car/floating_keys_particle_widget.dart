import 'dart:math';
import 'package:flutter/material.dart';

class FloatingKeysParticleWidget extends StatefulWidget {
  final bool active;
  final String lastChar;

  const FloatingKeysParticleWidget({
    super.key,
    required this.active,
    this.lastChar = '',
  });

  @override
  State<FloatingKeysParticleWidget> createState() => _FloatingKeysParticleWidgetState();
}

class _FloatingKeysParticleWidgetState extends State<FloatingKeysParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active && widget.lastChar.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          width: 45,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildKeyCube(
                char: widget.lastChar.isNotEmpty ? widget.lastChar : '⚡',
                offsetX: -12 - (_animController.value * 25),
                offsetY: sin(_animController.value * pi * 2) * 6,
                rotation: _animController.value * 0.4,
                opacity: (1.0 - _animController.value).clamp(0.0, 1.0),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyCube({
    required String char,
    required double offsetX,
    required double offsetY,
    required double rotation,
    required double opacity,
  }) {
    return Positioned(
      left: offsetX,
      top: 6 + offsetY,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Text(
              char.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
