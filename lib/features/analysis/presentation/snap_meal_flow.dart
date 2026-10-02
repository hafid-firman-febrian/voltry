import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/show_message.dart';
import '../data/photo_picker.dart';

/// How the Analyze page was closed.
enum AnalyzeExit { saved, retake }

/// Choose a source, pick a photo, analyze it. Starts over when the user taps
/// Retake on the Analyze page.
Future<void> snapMeal(BuildContext context, WidgetRef ref) async {
  var again = true;
  while (again) {
    if (!context.mounted) return;
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null || !context.mounted) return;

    final XFile? photo;
    try {
      photo = await ref.read(photoPickerProvider).pick(source);
    } on AppException catch (error) {
      if (context.mounted) showMessage(context, errorMessage(error));
      return;
    }
    if (photo == null || !context.mounted) return;

    final exit = await context.push<AnalyzeExit>(
      AppRoutes.analyze,
      extra: photo,
    );
    again = exit == AnalyzeExit.retake;
  }
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: const Text('Take photo'),
            onTap: () => Navigator.of(context).pop(PhotoSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
