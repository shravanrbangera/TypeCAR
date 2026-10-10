import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typeracer/models/car_model.dart';
import 'package:typeracer/models/player_model.dart';
import 'package:typeracer/services/typing_engine.dart';
import 'package:typeracer/widgets/car/car_preview_card.dart';
import 'package:typeracer/widgets/common/arcade_button.dart';
import 'package:typeracer/widgets/common/glowing_avatar.dart';
import 'package:typeracer/widgets/track/racing_track_widget.dart';
import 'package:typeracer/widgets/typing/typing_panel_widget.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('ArcadeButton renders and triggers callbacks', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArcadeButton(
              text: 'START RACE',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('START RACE'), findsOneWidget);
      await tester.tap(find.byType(ArcadeButton));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('GlowingAvatar renders icon and ready badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlowingAvatar(
              avatarIndex: 0,
              size: 50,
              isReady: true,
              showBadge: true,
            ),
          ),
        ),
      );

      expect(find.byType(GlowingAvatar), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('CarPreviewCard renders car details and stat bars', (WidgetTester tester) async {
      final car = CarModel.availableCars.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CarPreviewCard(
                car: car,
                selectedColor: const Color(0xFF00E5FF),
                isSelected: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text(car.name.toUpperCase()), findsOneWidget);
      expect(find.text('TOP SPEED'), findsOneWidget);
      expect(find.text('EQUIPPED'), findsOneWidget);
    });

    testWidgets('RacingTrackWidget renders multiple lanes and finish line', (WidgetTester tester) async {
      final players = [
        const PlayerModel(id: 'p1', nickname: 'Player 1', carColorValue: 0xFF00E5FF),
        const PlayerModel(id: 'p2', nickname: 'Player 2', carColorValue: 0xFFFF1744),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 250,
              width: 500,
              child: RacingTrackWidget(
                players: players,
                currentUserId: 'p1',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
      expect(find.text('🏁 FINISH'), findsOneWidget);
    });

    testWidgets('TypingPanelWidget renders and displays character spans', (WidgetTester tester) async {
      final engine = TypingEngine();
      engine.resetWithText('Hello Flutter');
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingPanelWidget(
              typingEngine: engine,
              textController: controller,
              focusNode: focusNode,
              isRaceActive: true,
            ),
          ),
        ),
      );

      expect(find.byType(TypingPanelWidget), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
    });
  });
}
