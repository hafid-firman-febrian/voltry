import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/photo_picker.dart';

import '../../../fakes/fake_food_analyzer.dart';
import '../../../fakes/fake_photo_picker.dart';
import '../../../helpers/pump_voltry_app.dart';

void main() {
  testWidgets('the camera button offers both photo sources', (tester) async {
    await pumpVoltryApp(tester);

    await tester.tap(find.byTooltip('Snap a meal'));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
  });

  testWidgets('denied camera access shows how to fix it and stays on Home', (
    tester,
  ) async {
    final picker = FakePhotoPicker(
      error: const PhotoAccessException('camera_access_denied'),
    );
    await pumpVoltryApp(tester, picker: picker);

    await tester.tap(find.byTooltip('Snap a meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        "Couldn't open the camera or photos. Check Voltry's access in Settings.",
      ),
      findsOneWidget,
    );
    expect(find.text('Snap your first meal of the day.'), findsOneWidget);
  });

  testWidgets('backing out of the picker does nothing', (tester) async {
    final picker = FakePhotoPicker(photo: null);
    final analyzer = FakeFoodAnalyzer([]);
    await pumpVoltryApp(tester, picker: picker, analyzer: analyzer);

    await tester.tap(find.byTooltip('Snap a meal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose from gallery'));
    await tester.pumpAndSettle();

    expect(picker.sources, [PhotoSource.gallery]);
    expect(analyzer.requests, isEmpty);
    expect(find.text('Snap your first meal of the day.'), findsOneWidget);
  });

  test('FakePhotoPicker returns the configured photo', () async {
    final photo = XFile('/tmp/meal.jpg');

    expect(await FakePhotoPicker(photo: photo).pick(PhotoSource.camera), photo);
  });

  testWidgets('the camera in the navbar also works from the History tab', (
    tester,
  ) async {
    await pumpVoltryApp(tester);
    await tester.tap(find.bySemanticsLabel('History'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Snap a meal'));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
  });
}
