import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/meal_log/data/photo_storage.dart';

void main() {
  late Directory root;
  late PhotoStorage storage;
  late XFile picked;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('voltry_photos_test');
    storage = PhotoStorage(Directory(p.join(root.path, 'meal_photos')));
    final source = File(p.join(root.path, 'image_picker_123.JPG'));
    await source.writeAsBytes([1, 2, 3]);
    picked = XFile(source.path);
  });

  tearDown(() => root.delete(recursive: true));

  test(
    'save copies the photo as <id><ext> and returns only the file name',
    () async {
      final fileName = await storage.save(picked, 'meal-1');

      expect(fileName, 'meal-1.jpg');
      expect(await storage.resolve(fileName)!.readAsBytes(), [1, 2, 3]);
    },
  );

  test(
    'save falls back to .jpg when the picked file has no extension',
    () async {
      final noExtension = File(p.join(root.path, 'camera_output'));
      await noExtension.writeAsBytes([9]);

      expect(
        await storage.save(XFile(noExtension.path), 'meal-2'),
        'meal-2.jpg',
      );
    },
  );

  test('resolve returns null for a missing file', () {
    expect(storage.resolve('gone.jpg'), isNull);
  });

  test(
    'delete removes the file and ignores files that are already gone',
    () async {
      final fileName = await storage.save(picked, 'meal-3');

      await storage.delete(fileName);
      await storage.delete(fileName);

      expect(storage.resolve(fileName), isNull);
    },
  );

  test('readBytes wraps file errors in StorageException', () {
    expect(
      () => storage.readBytes(XFile(p.join(root.path, 'missing.jpg'))),
      throwsA(isA<StorageException>()),
    );
  });
}
