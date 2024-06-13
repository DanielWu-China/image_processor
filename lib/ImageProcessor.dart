import 'package:flutter/services.dart';

class ImageProcessor {
  static const MethodChannel _channel = MethodChannel('image_processor');

  Future<String?> cutoutImage(String originPath, String maskPath) async {
    try {
      final String? result = await _channel.invokeMethod('cutoutImage', {
        'originPath': originPath,
        'maskPath': maskPath,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to cutout image: '${e.message}'.");
      return null;
    }
  }
}
