import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/voltry_theme.dart';

class VoltryApp extends ConsumerWidget {
  const VoltryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Voltry',
      debugShowCheckedModeBanner: false,
      theme: buildVoltryTheme(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
