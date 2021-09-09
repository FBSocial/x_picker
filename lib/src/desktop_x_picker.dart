import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:x_picker/src/x_picker.dart';

class DesktopXPicker extends XPicker {
  @override
  Future<List<XFile>> pickMultiImages(
      {PickImageMobileOptions? mobileOptions,
      PickImageDesktopOptions? desktopOptions}) async {
    desktopOptions ??= PickImageDesktopOptions();

    final res = await FilePicker.platform.pickFiles(
      dialogTitle: desktopOptions.dialogTitle,
      onFileLoading: desktopOptions.onFileLoading,
      allowCompression: desktopOptions.allowCompression,
      allowMultiple: true,
      type: FileType.image,
    );

    if (res == null) return const [];

    return res.paths
        .map((e) => XFile(
              e!,
              mimeType: lookupMimeType(e),
            ))
        .toList();
  }

  @override
  Future<XFile?> pickMedia(
      {required MediaType type,
      PickImageMobileOptions? mobileOptions,
      PickImageDesktopOptions? desktopOptions}) async {
    desktopOptions ??= PickImageDesktopOptions();

    FileType fileType;
    switch (type) {
      case MediaType.IMAGE:
        fileType = FileType.image;
        break;
      case MediaType.VIDEO:
        fileType = FileType.video;
        break;
      case MediaType.BOTH:
        fileType = FileType.media;
        break;
    }
    var result = await FilePicker.platform.pickFiles(
      dialogTitle: desktopOptions.dialogTitle,
      onFileLoading: desktopOptions.onFileLoading,
      allowCompression: desktopOptions.allowCompression,
      withData: kIsWeb ? true : false,
      // web 暂不支持 media 类型
      type: (kIsWeb && fileType == FileType.media) ? FileType.custom : fileType,
      // 仅 web 生效
      allowedExtensions: [
        "jpg",
        "png",
        "gif",
        "tiff",
        "mpg",
        "mpeg",
        "mp3",
        "mp4",
        "avi",
        "rmvb",
        "mov",
        "wmv"
      ],
    );

    if (result != null) {
      if (kIsWeb) {
        final file = result.files.single;
        return XFile.fromData(
          file.bytes!,
          name: file.name,
          length: file.size,
          mimeType: lookupMimeType(file.name),
        );
      }
      final path = result.files.single.path;
      return XFile(path, mimeType: lookupMimeType(path));
    } else {
      return null;
    }
  }
}
