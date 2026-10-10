import 'package:flutter/material.dart';

class NitroFlameWidget extends StatefulWidget {
  final bool active;
  const NitroFlameWidget({super.key, required this.active});

  @override
  State<NitroFlameWidget> createState() => _NitroFlameWidgetState();
}

class _NitroFlameWidgetState extends State<NitroFlameWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.8 + (_controller.value * 0.4);
        return Transform.scale(
          scale: scale,
          alignment: Alignment.centerRight,
          child: Container(
            width: 32,
            height: 18,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF),
                  const Color(0xFFFF9100),
                  const Color(0xFFFF1744).withValues(alpha: 0.0),
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
          ),
        );
      },
    );
  }
}
