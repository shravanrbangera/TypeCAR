import 'package:flutter/material.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ArcadeButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color primaryColor;
  final Color textColor;
  final double height;
  final double? width;
  final bool isLoading;
  final bool isSecondary;

  const ArcadeButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.primaryColor = AppColors.electricCyan,
    this.textColor = Colors.black,
    this.height = 58,
    this.width,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  State<ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<ArcadeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 90),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      AudioController.playKeyClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: enabled ? widget.onPressed : null,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isSecondary
                ? const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: enabled
                        ? [
                            widget.primaryColor,
                            HSLColor.fromColor(widget.primaryColor).withLightness(0.4).toColor(),
                          ]
                        : [Colors.grey.shade700, Colors.grey.shade800],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            border: Border.all(
              color: widget.isSecondary
                  ? (enabled ? widget.primaryColor : Colors.grey.shade700)
                  : Colors.white.withValues(alpha: 0.4),
              width: widget.isSecondary ? 2.0 : 1.5,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                    const BoxShadow(
                      color: Colors.black45,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top Highlight Bevel Sheen
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: widget.textColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isSecondary ? widget.primaryColor : widget.textColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text.toUpperCase(),
                            style: AppTypography.buttonText.copyWith(
                              fontSize: 15,
                              letterSpacing: 1.5,
                              color: widget.isSecondary ? widget.primaryColor : widget.textColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
