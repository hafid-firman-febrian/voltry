import 'package:flutter_test/flutter_test.dart';
import 'package:voltry/features/analysis/domain/nutrition_analysis_model.dart';
import 'package:voltry/features/analysis/presentation/widgets/nutrition_card.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the estimate with an AI badge and macro chips', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      const NutritionCard(
        analysis: NutritionAnalysis(
          foodName: 'Nasi goreng',
          calories: 1450,
          proteinG: 20,
          carbsG: 80,
          fatG: 25,
        ),
      ),
    );

    expect(find.text('AI ESTIMATE'), findsOneWidget);
    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(find.text('1,450'), findsOneWidget);
    expect(find.text('Protein 20 g'), findsOneWidget);
    expect(find.text('Carbs 80 g'), findsOneWidget);
    expect(find.text('Fat 25 g'), findsOneWidget);
  });
}
