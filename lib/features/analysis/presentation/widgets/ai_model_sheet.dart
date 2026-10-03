import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/show_message.dart';
import '../../domain/ai_model.dart';
import '../controllers/ai_model_controller.dart';

/// True only when the user picked a different model and it was saved, so the
/// caller knows whether analyzing again could give another answer.
Future<bool> showAiModelSheet(BuildContext context, WidgetRef ref) async {
  final current = ref.read(aiModelControllerProvider);
  final picked = await showModalBottomSheet<AiModel>(
    context: context,
    // Home lives inside a tab navigator under the floating navbar. The root
    // navigator puts the sheet and its barrier above the navbar, like the
    // photo source sheet.
    useRootNavigator: true,
    builder: (_) => AiModelSheet(selected: current),
  );
  if (picked == null || picked == current || !context.mounted) return false;
  try {
    await ref.read(aiModelControllerProvider.notifier).select(picked);
  } on AppException catch (error) {
    if (context.mounted) showMessage(context, errorMessage(error));
    return false;
  }
  if (context.mounted) showMessage(context, 'Now using ${picked.label}');
  return true;
}

class AiModelSheet extends StatelessWidget {
  const AiModelSheet({super.key, required this.selected});

  final AiModel selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI model', style: text.subtitle),
                const SizedBox(height: 4),
                Text(
                  'Each model has its own free daily limit.',
                  style: text.bodySmall.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          for (final model in AiModel.values)
            ListTile(
              title: Text(model.label),
              // A trailing check instead of Radio, which keeps changing its
              // API across Flutter releases.
              trailing: model == selected
                  ? Icon(Icons.check_rounded, color: colors.coral)
                  : null,
              onTap: () => Navigator.of(context).pop(model),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
