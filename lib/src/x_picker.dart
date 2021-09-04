import 'dart:core';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:x_picker/src/desktop_x_picker.dart';
import 'package:x_picker/src/non_desktop_x_picker.dart';

class PickImageMobileOptions {
  final ImageSource source;
  final double? maxWidth;
  final double? maxHeight;
  final int? imageQuality;
  final CameraDevice preferredCameraDevice;

  PickImageMobileOptions({
    this.source = ImageSource.gallery,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
  });
}

class PickImageDesktopOptions {
  final String? dialogTitle;
  final Function(FilePickerStatus)? onFileLoading;
  final bool allowCompression;

  const PickImageDesktopOptions(
      {this.dialogTitle, this.onFileLoading, this.allowCompression = true});
}

class PickVideoMobileOptions extends PickImageMobileOptions {}

class PickVideoDesktopOptions extends PickImageDesktopOptions {}

/// [pickMedia] 的类型，传入 `MediaType.IMAGE | MediaType.VIDEO` 可以选取
/// 图片 + 视频，但是移动端暂不支持组合
enum MediaType {
  IMAGE,
  VIDEO,
  BOTH,
}

abstract class XPicker {
  static fromPlatform() {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      return NonDesktopXPicker();
    }
    return DesktopXPicker();
  }

  /// 选取单张图片，仅桌面端支持同时识别图片和视频
  /// 现阶段，移动端返回的 mimeType 为 null
  Future<XFile?> pickMedia({
    required MediaType type,
    PickImageMobileOptions? mobileOptions,
    PickImageDesktopOptions? desktopOptions,
  });

  Future<List<XFile>> pickMultiImages({
    PickImageMobileOptions? mobileOptions,
    PickImageDesktopOptions? desktopOptions,
  });

  /// 选择文件
  /// [withData] 为 true 会读取文件流到内存中，如果需要兼容 web 端，请设置为 true
  Future<List<XFile>> pickFiles({
    String? dialogTitle,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    bool allowMultiple = false,
    bool withData = false,
  }) async {
    assert((() {
      if (kIsWeb) {
        assert(withData, "[XPicker.pickFiles] 如果需要兼容 Web 端，请使用 withData 获取数据");
      }
      return true;
    }()));

    final files = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
      allowCompression: allowCompression,
      allowMultiple: allowMultiple,
      withData: withData,
    );
    if (files == null) return const [];

    if (kIsWeb) {
      return files.files
          .map((e) => XFile.fromData(
                e.bytes!,
                name: e.name,
                mimeType: lookupMimeType(e.name),
              ))
          .toList();
    } else {
      return files.paths
          .map((e) => XFile(e!, mimeType: lookupMimeType(e)))
          .toList();
    }
  }
}
