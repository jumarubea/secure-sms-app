import 'package:flutter/services.dart';

class SmsPlatformService {
  static const MethodChannel _channel = MethodChannel('sms_default_channel');

  static Future<void> requestDefaultSmsApp() async {
    try {
      await _channel.invokeMethod('requestDefaultSmsApp');
    } on PlatformException catch (e) {
      // Handle error
      print('Failed to request default SMS app: ${e.message}');
    }
  }

  static Future<bool> isDefaultSmsApp() async {
    try {
      final bool isDefault = await _channel.invokeMethod('isDefaultSmsApp');
      return isDefault;
    } on PlatformException catch (e) {
      // Handle error
      print('Failed to check if default SMS app: ${e.message}');
      return false;
    }
  }
}
