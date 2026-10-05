import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/show_message.dart';
import '../controllers/sign_in_controller.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Voltry',
                    style: text.display.copyWith(color: colors.onCoral),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Snap a meal, get its calories and macros.',
                style: text.body.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Continue with Google',
                isLoading: signingIn,
                onPressed: () =>
                    ref.read(signInControllerProvider.notifier).signIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
