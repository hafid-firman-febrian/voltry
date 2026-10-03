import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/show_message.dart';
import '../controllers/analyze_controller.dart';
import '../snap_meal_flow.dart';
import '../states/analyze_state.dart';
import '../widgets/ai_model_sheet.dart';
import '../widgets/nutrition_card.dart';

class AnalyzePage extends ConsumerWidget {
  const AnalyzePage({super.key, required this.photo});

  static const loadingAnimation = 'assets/animations/loading.json';

  final XFile photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = analyzeControllerProvider(photo);
    final state = ref.watch(provider);
    void retake() => context.pop(AnalyzeExit.retake);

    return Scaffold(
      appBar: AppBar(title: const Text('Your meal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(VoltryRadius.cardLarge),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: context.colors.line),
                ),
              ),
            ),
            const SizedBox(height: 16),
            switch (state) {
              AnalyzeLoading() => const _Analyzing(),
              AnalyzeResult(:final analysis, :final isSaving) => Column(
                children: [
                  NutritionCard(analysis: analysis),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save',
                    isLoading: isSaving,
                    onPressed: () => _save(context, ref),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Retake',
                    icon: Icons.photo_camera_rounded,
                    onPressed: isSaving ? null : retake,
                  ),
                ],
              ),
              AnalyzeNotFood() => Column(
                children: [
                  const _Notice(
                    icon: Icons.no_food_outlined,
                    message: 'No food found in this photo.',
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Retake', onPressed: retake),
                ],
              ),
              AnalyzeFailure(:final error) => Column(
                children: [
                  _Notice(
                    icon: Icons.cloud_off_rounded,
                    message: errorMessage(error),
                  ),
                  const SizedBox(height: 16),
                  if (error is AiQuotaException) ...[
                    PrimaryButton(
                      label: 'Switch AI model',
                      onPressed: () => _switchModel(context, ref),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'Try again',
                      onPressed: () => ref.read(provider.notifier).retry(),
                    ),
                  ] else
                    PrimaryButton(
                      label: 'Try again',
                      onPressed: () => ref.read(provider.notifier).retry(),
                    ),
                  const SizedBox(height: 12),
                  SecondaryButton(label: 'Retake', onPressed: retake),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }

  // Every model has its own free quota, so the same photo is worth sending
  // again only when the user actually picked a different model.
  Future<void> _switchModel(BuildContext context, WidgetRef ref) async {
    final switched = await showAiModelSheet(context, ref);
    if (switched && context.mounted) {
      await ref.read(analyzeControllerProvider(photo).notifier).retry();
    }
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(analyzeControllerProvider(photo).notifier).save();
      if (context.mounted) context.pop(AnalyzeExit.saved);
    } on AppException catch (error) {
      if (context.mounted) showMessage(context, errorMessage(error));
    }
  }
}

class _Analyzing extends StatelessWidget {
  const _Analyzing();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          AnalyzePage.loadingAnimation,
          width: 140,
          height: 140,
          // Keeps the page usable before the animation file is added and in
          // tests, where the asset is not bundled.
          errorBuilder: (_, _, _) => const SizedBox.square(
            dimension: 140,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        Text('Analyzing your meal…', style: context.textStyles.subtitle),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.muted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyles.subtitle,
          ),
        ],
      ),
    );
  }
}
