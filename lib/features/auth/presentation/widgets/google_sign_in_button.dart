import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  static const _logoSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.ink,
          disabledBackgroundColor: colors.surface,
          disabledForegroundColor: colors.muted,
          side: BorderSide(color: colors.line),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: context.textStyles.subtitle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The spinner takes the logo's place and size, so the button
            // keeps its width while Google is open.
            SizedBox.square(
              dimension: _logoSize,
              child: isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.ink,
                    )
                  // Google's own G, unaltered, as its branding rules require.
                  : Image.asset(
                      'assets/images/google-logo.png',
                      excludeFromSemantics: true,
                    ),
            ),
            const SizedBox(width: 12),
            // Shrinks instead of overflowing on a narrow screen or with
            // large text.
            const Flexible(
              child: Text(
                'Continue with Google',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
