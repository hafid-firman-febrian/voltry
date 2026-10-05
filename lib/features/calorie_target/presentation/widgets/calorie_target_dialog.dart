import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/show_message.dart';
import '../../domain/calorie_target_rules.dart';
import '../controllers/calorie_target_controller.dart';

/// Asks for a new daily target and saves it. Shows a snack bar when saving
/// fails, keeping the old target.
Future<void> editCalorieTarget(BuildContext context, WidgetRef ref) async {
  final kcal = await showDialog<int>(
    context: context,
    // Home offers this only once the target has loaded.
    builder: (_) => CalorieTargetDialog(
      initial: ref.read(calorieTargetControllerProvider).requireValue,
    ),
  );
  if (kcal == null || !context.mounted) return;
  try {
    await ref.read(calorieTargetControllerProvider.notifier).save(kcal);
  } on AppException catch (error) {
    if (context.mounted) showMessage(context, errorMessage(error));
  }
}

class CalorieTargetDialog extends StatefulWidget {
  const CalorieTargetDialog({super.key, required this.initial});

  final int initial;

  @override
  State<CalorieTargetDialog> createState() => _CalorieTargetDialogState();
}

class _CalorieTargetDialogState extends State<CalorieTargetDialog> {
  late final _controller = TextEditingController(text: '${widget.initial}');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily calorie target'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(suffixText: 'kcal', errorText: _error),
        onChanged: (value) =>
            setState(() => _error = CalorieTargetRules.validate(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _error == null
              ? () => Navigator.of(
                  context,
                ).pop(CalorieTargetRules.parse(_controller.text))
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
