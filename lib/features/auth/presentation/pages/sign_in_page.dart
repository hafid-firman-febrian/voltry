import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../../../core/widgets/show_message.dart';
import '../controllers/sign_in_controller.dart';
import '../widgets/google_sign_in_button.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  static const _iconSize = 96.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.textStyles;
    ref.listen(signInControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showMessage(context, errorMessage(error));
      }
    });
    final signingIn = ref.watch(signInControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Grouped in the middle rather than pinned to the bottom, where the
          // error snack bar would cover the button the user needs to retry.
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // The launcher icon source is a full square; rounding it here
                // makes it look like the icon on the home screen.
                ClipRRect(
                  borderRadius: BorderRadius.circular(VoltryRadius.cardLarge),
                  child: Image.asset(
                    'assets/icon/voltry-app-icon.png',
                    width: _iconSize,
                    height: _iconSize,
                    // The source is 1024 px; decoding it at display size
                    // keeps a ~4 MB bitmap out of memory.
                    cacheWidth:
                        (_iconSize * MediaQuery.devicePixelRatioOf(context))
                            .round(),
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(height: 24),
                Text('Voltry', style: text.display),
                const SizedBox(height: 8),
                Text(
                  'Snap a meal, get its calories and macros.',
                  textAlign: TextAlign.center,
                  style: text.body.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 32),
                GoogleSignInButton(
                  isLoading: signingIn,
                  onPressed: () =>
                      ref.read(signInControllerProvider.notifier).signIn(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
