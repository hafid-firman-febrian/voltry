import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context.dart';
import '../controllers/ai_model_controller.dart';
import 'ai_model_sheet.dart';

/// Names the active model, so the owner can see whose free quota the next
/// analysis uses without opening the sheet.
class AiModelButton extends ConsumerWidget {
  const AiModelButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final model = ref.watch(aiModelControllerProvider);

    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () => showAiModelSheet(context, ref),
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.line),
          shape: const StadiumBorder(),
          textStyle: context.textStyles.subtitle,
          padding: const EdgeInsets.only(left: 16, right: 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                model.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
