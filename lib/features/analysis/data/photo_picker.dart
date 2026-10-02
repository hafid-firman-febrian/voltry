import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';

enum PhotoSource { camera, gallery }

final photoPickerProvider = Provider<PhotoPicker>(
  (ref) => PhotoPicker(ImagePicker()),
);

class PhotoPicker {
  PhotoPicker(this._picker);

  final ImagePicker _picker;

  /// The picked photo, resized for a faster upload, or null when the user
  /// backs out. Throws [PhotoAccessException] when access is denied or no
  /// camera exists (for example on the iOS simulator).
  Future<XFile?> pick(PhotoSource source) async {
    try {
      return await _picker.pickImage(
        source: switch (source) {
          PhotoSource.camera => ImageSource.camera,
          PhotoSource.gallery => ImageSource.gallery,
        },
        maxWidth: 1024,
        imageQuality: 85,
      );
    } on PlatformException catch (error) {
      throw PhotoAccessException(error.code);
    }
  }
}
