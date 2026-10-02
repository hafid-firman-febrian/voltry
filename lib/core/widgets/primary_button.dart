import 'package:flutter/material.dart';

import '../theme/theme_context.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.coral,
          foregroundColor: colors.onCoral,
          disabledBackgroundColor: colors.coral.withValues(alpha: 0.4),
          disabledForegroundColor: colors.onCoral,
          shape: const StadiumBorder(),
          textStyle: context.textStyles.subtitle,
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colors.onCoral,
                ),
              )
            : Text(label),
      ),
    );
  }
}
