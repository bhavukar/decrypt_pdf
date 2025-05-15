// lib/decrypt_pdf_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'decrypt_pdf_platform_interface.dart';

class MethodChannelDecryptPdf extends DecryptPdfPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('decrypt_pdf');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<bool> isPdfProtected({required String filePath}) async {
    try {
      final bool result = await methodChannel.invokeMethod('isPdfProtected', {
        'filePath': filePath,
      });
      return result;
    } on PlatformException catch (e) {
      print("Failed to check if PDF is protected: '${e.message}'.");
      rethrow;
    }
  }

  @override
  Future<String?> openPdf({
    required String filePath,
    required String password,
  }) async {
    try {
      final String? decryptedFilePath = await methodChannel.invokeMethod(
        'openPdf',
        {'filePath': filePath, 'password': password},
      );
      return decryptedFilePath;
    } on PlatformException catch (e) {
      print("Failed to open PDF: '${e.message}'.");
      rethrow;
    }
  }
}
