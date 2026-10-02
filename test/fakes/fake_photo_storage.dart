import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';

class FakePhotoStorage implements PhotoStorage {
  final saved = <String>[];
  final deleted = <String>[];

  AppException? failSaveWith;
  AppException? failDeleteWith;

  @override
  Directory get directory => Directory('/fake/meal_photos');

  @override
  Future<Uint8List> readBytes(XFile photo) async =>
      Uint8List.fromList([1, 2, 3]);

  @override
  Future<String> save(XFile photo, String id) async {
    final error = failSaveWith;
    if (error != null) throw error;
    final fileName = '$id.jpg';
    saved.add(fileName);
    return fileName;
  }

  @override
  File? resolve(String fileName) => null;

  @override
  Future<void> delete(String fileName) async {
    final error = failDeleteWith;
    if (error != null) throw error;
    deleted.add(fileName);
  }
}
