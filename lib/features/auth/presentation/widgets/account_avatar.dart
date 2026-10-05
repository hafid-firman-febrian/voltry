import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context.dart';
import '../../domain/account_rules.dart';
import '../../domain/app_user_model.dart';
import '../controllers/auth_state_controller.dart';
import 'account_sheet.dart';

/// The Google profile photo, or the user's initial on coral when there is no
/// photo or it fails to load.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.user, this.size = 38});

  final AppUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final photoUrl = user.photoUrl;
    // FittedBox scales the letter with the circle, so the same widget works
    // in the header and, larger, in the account sheet.
    final initial = Padding(
      padding: EdgeInsets.all(size * 0.28),
      child: FittedBox(
        child: Text(
          initialOf(user),
          style: context.textStyles.subtitle.copyWith(color: colors.onCoral),
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.coral,
        shape: BoxShape.circle,
        border: Border.all(color: colors.line),
      ),
      child: photoUrl == null
          ? initial
          : Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => initial,
            ),
    );
  }
}

/// The avatar in the Home header. Opens the account sheet.
class AccountButton extends ConsumerWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Account',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showAccountSheet(context, ref),
        child: AccountAvatar(user: ref.watch(currentUserProvider)),
      ),
    );
  }
}
