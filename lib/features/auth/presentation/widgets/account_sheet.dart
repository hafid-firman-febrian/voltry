import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/theme_context.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/show_message.dart';
import '../../domain/app_user_model.dart';
import '../controllers/auth_state_controller.dart';
import 'account_avatar.dart';

/// Shows who is signed in, with Sign out behind a confirmation. Signing out
/// needs no navigation here: the router's redirect moves to Sign in.
Future<void> showAccountSheet(BuildContext context, WidgetRef ref) async {
  final signOut = await showModalBottomSheet<bool>(
    context: context,
    // Above the floating navbar, like the AI model and photo sheets.
    useRootNavigator: true,
    builder: (_) => AccountSheet(user: ref.read(currentUserProvider)),
  );
  if (signOut != true || !context.mounted) return;
  try {
    await ref.read(authStateProvider.notifier).signOut();
  } on AppException catch (error) {
    if (context.mounted) showMessage(context, errorMessage(error));
  }
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.textStyles;
    final name = user.displayName;
    final email = user.email;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccountAvatar(user: user, size: 64),
            const SizedBox(height: 12),
            if (name != null) Text(name, style: text.subtitle),
            if (email != null)
              Text(email, style: text.body.copyWith(color: colors.muted)),
            const SizedBox(height: 20),
            SecondaryButton(
              label: 'Sign out',
              icon: Icons.logout_rounded,
              onPressed: () async {
                final confirmed = await _confirmSignOut(context);
                if (confirmed && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out of Voltry?'),
        content: const Text('Your meals stay in your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
