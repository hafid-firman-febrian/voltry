import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context.dart';
import '../../../../core/theme/voltry_radius.dart';
import '../../data/photo_storage.dart';

/// A stored meal photo, or a placeholder when the file is gone.
class MealPhoto extends ConsumerWidget {
  const MealPhoto({
    super.key,
    required this.fileName,
    this.size,
    this.radius = VoltryRadius.thumbnail,
  });

  final String fileName;

  /// Square size. Null fills the parent.
  final double? size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final file = ref.watch(photoStorageProvider).resolve(fileName);
    final size = this.size;
    final placeholder = ColoredBox(
      color: colors.background,
      child: Center(child: Icon(Icons.restaurant_rounded, color: colors.muted)),
    );

    final image = file == null
        ? placeholder
        : Image.file(
            file,
            fit: BoxFit.cover,
            cacheWidth: size == null
                ? null
                : (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => placeholder,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: size == null
          ? SizedBox.expand(child: image)
          : SizedBox.square(dimension: size, child: image),
    );
  }
}
