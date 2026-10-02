import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/core/theme/voltry_colors.dart';
import 'package:voltry/core/widgets/calorie_ring.dart';
import 'package:voltry/core/widgets/error_view.dart';
import 'package:voltry/core/widgets/hero_card.dart';
import 'package:voltry/core/widgets/pill_badge.dart';
import 'package:voltry/core/widgets/primary_button.dart';
import 'package:voltry/core/widgets/stat_tile.dart';
import 'package:voltry/core/widgets/voltry_nav_bar.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('HeroCard renders its child on coral', (tester) async {
    await pumpThemed(
      tester,
      const HeroCard(child: PillBadge(label: 'Today', showBolt: true)),
    );

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsNWidgets(2));
  });

  testWidgets('StatTile shows value and label', (tester) async {
    await pumpThemed(
      tester,
      const StatTile(
        icon: Icons.egg_alt_outlined,
        value: '32 g',
        label: 'Protein',
        tone: StatTone.blue,
      ),
    );

    expect(find.text('32 g'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
  });

  testWidgets('PrimaryButton shows a spinner and ignores taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await pumpThemed(
      tester,
      PrimaryButton(label: 'Save', isLoading: true, onPressed: () => taps++),
    );

    await tester.tap(find.byType(PrimaryButton));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    expect(taps, 0);
  });

  testWidgets('CalorieRing shows its label and caption, even past 100%', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      const CalorieRing(progress: 1.6, label: '160%', caption: 'of target'),
    );

    expect(find.text('160%'), findsOneWidget);
    expect(find.text('of target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ErrorView calls onRetry', (tester) async {
    var retried = false;
    await pumpThemed(
      tester,
      ErrorView(message: 'Boom', onRetry: () => retried = true),
    );

    await tester.tap(find.text('Retry'));
    expect(find.text('Boom'), findsOneWidget);
    expect(retried, isTrue);
  });

  testWidgets('VoltryNavBar reports the tapped tab and marks the active one', (
    tester,
  ) async {
    int? selected;
    await pumpThemed(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: VoltryNavBar(
          currentIndex: 0,
          onSelected: (index) => selected = index,
          items: const [
            VoltryNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              color: Color(0xFFFF5A5F),
              onColor: Color(0xFFFFFFFF),
            ),
            VoltryNavItem(
              icon: Icons.history_rounded,
              label: 'History',
              color: Color(0xFF3A86FF),
              onColor: Color(0xFFFFFFFF),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.history_rounded));
    expect(selected, 1);

    final activeIcon = tester.widget<Icon>(find.byIcon(Icons.home_rounded));
    expect(activeIcon.color, VoltryColors.light.onCoral);
  });
}
