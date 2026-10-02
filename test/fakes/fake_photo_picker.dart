import 'package:image_picker/image_picker.dart';
import 'package:voltry/core/errors/app_exception.dart';
import 'package:voltry/features/analysis/data/photo_picker.dart';

class FakePhotoPicker implements PhotoPicker {
  FakePhotoPicker({this.photo, this.error});

  /// Returned by every pick. Null means the user backed out.
  XFile? photo;
  AppException? error;
  final sources = <PhotoSource>[];

  @override
  Future<XFile?> pick(PhotoSource source) async {
    sources.add(source);
    final failure = error;
    if (failure != null) throw failure;
    return photo;
  }
}
