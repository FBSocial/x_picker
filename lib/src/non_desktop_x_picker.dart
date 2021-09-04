import 'package:image_picker/image_picker.dart';
import 'package:x_picker/src/x_picker.dart';

class NonDesktopXPicker extends XPicker {
  late ImagePicker _imagePicker = ImagePicker();

  @override
  Future<List<XFile>> pickMultiImages(
      {PickImageMobileOptions? mobileOptions,
      PickImageDesktopOptions? desktopOptions}) async {
    mobileOptions ??= PickImageMobileOptions();
    return (await _imagePicker.pickMultiImage(
          maxWidth: mobileOptions.maxWidth,
          maxHeight: mobileOptions.maxHeight,
          imageQuality: mobileOptions.imageQuality,
        ) ??
        const []);
  }

  @override
  Future<XFile?> pickMedia(
      {required MediaType type,
      PickImageMobileOptions? mobileOptions,
      PickImageDesktopOptions? desktopOptions}) {
    mobileOptions ??= PickImageMobileOptions();

    if (type == MediaType.BOTH) {
      print("[XPicker.pickMedia] mobile or web doesn't support MediaType.BOTH");
      type = MediaType.IMAGE;
    }

    if (type == MediaType.IMAGE) {
      return _imagePicker.pickImage(
        source: mobileOptions.source,
        maxWidth: mobileOptions.maxWidth,
        maxHeight: mobileOptions.maxHeight,
        preferredCameraDevice: mobileOptions.preferredCameraDevice,
      );
    } else {
      return _imagePicker.pickVideo(
        source: mobileOptions.source,
        preferredCameraDevice: mobileOptions.preferredCameraDevice,
      );
    }
  }
}
