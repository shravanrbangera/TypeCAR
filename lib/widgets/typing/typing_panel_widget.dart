import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/typing_engine.dart';
import 'nitro_bottle_widget.dart';

class TypingPanelWidget extends StatefulWidget {
  final TypingEngine typingEngine;
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isRaceActive;
  final int position;
  final int totalRacers;

  const TypingPanelWidget({
    super.key,
    required this.typingEngine,
    required this.textController,
    required this.focusNode,
    required this.isRaceActive,
    this.position = 1,
    this.totalRacers = 1,
  });

  @override
  State<TypingPanelWidget> createState() => _TypingPanelWidgetState();
}

class _TypingPanelWidgetState extends State<TypingPanelWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.typingEngine.targetText;
    final userInput = widget.typingEngine.userInput;
    final hasError = widget.typingEngine.incorrectCharactersCount > 0;
    final streak = widget.typingEngine.currentStreak;
    final isNitro = widget.typingEngine.isNitroActive;

    return GestureDetector(
      onTap: () {
        if (widget.isRaceActive) {
          widget.focusNode.requestFocus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          gradient: const LinearGradient(
            colors: [Color(0xFF131D31), Color(0xFF090E1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: hasError
                ? AppColors.neonPink
                : (isNitro ? AppColors.neonOrange : AppColors.electricCyan),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasError
                      ? AppColors.neonPink
                      : (isNitro ? AppColors.neonOrange : AppColors.electricCyan))
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top Cockpit Bezel Arc Accent
            Positioned(
              top: 0,
              left: 40,
              right: 40,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      hasError
                          ? AppColors.neonPink
                          : (isNitro ? AppColors.neonOrange : AppColors.electricCyan),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- LEFT COCKPIT TELEMETRY (WPM, ACCURACY, POSITION) ---
                  SizedBox(
                    width: 76,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WPM Gauge
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Text(
                                'WPM',
                                style: AppTypography.hudLabel.copyWith(fontSize: 9, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.typingEngine.currentWpm.toInt()}',
                                style: AppTypography.hudValue.copyWith(
                                  fontSize: 16,
                                  color: AppColors.electricCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Accuracy
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Text(
                                'ACC',
                                style: AppTypography.hudLabel.copyWith(fontSize: 9, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.typingEngine.accuracy.toInt()}%',
                                style: AppTypography.hudValue.copyWith(
                                  fontSize: 13,
                                  color: widget.typingEngine.accuracy > 90
                                    ? AppColors.electricGreen
                                    : AppColors.neonPink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Position Badge
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1),
                            ),
                            child: Text(
                              'POS #${widget.position}',
                              style: AppTypography.hudLabel.copyWith(
                                fontSize: 9,
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // --- CENTER ILLUMINATED TYPING WHITE/LIGHT CARD ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // Clean readable crisp paper background like Reference 1
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 85, maxHeight: 125),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: _buildRichTextSpan(target, userInput),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Sub Status Pill (Mistake Warning or Streak Message)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (hasError)
                                Text(
                                  '⚠️ PRESS BACKSPACE TO FIX ERROR',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                )
                              else if (streak >= 10)
                                Text(
                                  '🔥 $streak STREAK COMBO!',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              else
                                Text(
                                  '🏎️ TYPE EVERY LETTER PRECISELY',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              Text(
                                '${(widget.typingEngine.progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // --- RIGHT NITRO BOTTLE CANISTER ---
                  NitroBottleWidget(
                    streak: streak,
                    isNitroActive: isNitro,
                  ),
                ],
              ),
            ),
            // Hidden Input Capturer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 1,
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  controller: widget.textController,
                  focusNode: widget.focusNode,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.none,
                  enabled: widget.isRaceActive && !widget.typingEngine.isFinished,
                  onChanged: (text) {
                    widget.typingEngine.handleInputChanged(text);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichTextSpan(String target, String input) {
    if (target.isEmpty) {
      return const Text('Loading race text...', style: TextStyle(color: Colors.black54));
    }

    final spans = <TextSpan>[];
    final inputLen = input.length;
    final targetLen = target.length;

    int firstErrorIndex = -1;
    for (int i = 0; i < inputLen; i++) {
      if (i >= targetLen || input[i] != target[i]) {
        firstErrorIndex = i;
        break;
      }
    }

    for (int i = 0; i < targetLen; i++) {
      final char = target[i];
      TextStyle charStyle;

      if (i < inputLen) {
        if (firstErrorIndex == -1 || i < firstErrorIndex) {
          // Completed Correct character (Dark slate text)
          charStyle = const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
            letterSpacing: 0.5,
          );
        } else {
          // Incorrect character (Bright Red Box with underline)
          charStyle = TextStyle(
            color: Colors.white,
            backgroundColor: Colors.red.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            decoration: TextDecoration.underline,
          );
        }
      } else if (i == inputLen) {
        // Current Target Character (Bright Blue highlighted block with cursor box)
        charStyle = const TextStyle(
          color: Colors.white,
          backgroundColor: Color(0xFF0284C7),
          fontSize: 17,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        );
      } else {
        // Upcoming unreached characters (High-contrast dark sharp text)
        charStyle = const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          letterSpacing: 0.5,
        );
      }

      spans.add(TextSpan(text: char, style: charStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
