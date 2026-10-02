import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/errors/app_exception.dart';

/// Overridden in main() once the documents directory is known.
final photoStorageProvider = Provider<PhotoStorage>(
  (ref) => throw UnimplementedError('Override photoStorageProvider in main()'),
);

/// Owns the meal photo files. The database stores only file names, because
/// the documents directory path on iOS changes on every reinstall and update.
class PhotoStorage {
  PhotoStorage(this.directory);

  final Directory directory;

  Future<Uint8List> readBytes(XFile photo) => _guard(photo.readAsBytes);

  /// Copies [photo] to `<directory>/<id><ext>` and returns the file name.
  Future<String> save(XFile photo, String id) => _guard(() async {
    final extension = p.extension(photo.path).toLowerCase();
    final fileName = '$id${extension.isEmpty ? '.jpg' : extension}';
    await directory.create(recursive: true);
    await photo.saveTo(p.join(directory.path, fileName));
    return fileName;
  });

  /// The stored file, or null when it no longer exists.
  File? resolve(String fileName) {
    final file = File(p.join(directory.path, fileName));
    return file.existsSync() ? file : null;
  }

  Future<void> delete(String fileName) => _guard(() async {
    final file = File(p.join(directory.path, fileName));
    if (await file.exists()) await file.delete();
  });

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on FileSystemException catch (error) {
      throw StorageException(error.toString());
    }
  }
}
