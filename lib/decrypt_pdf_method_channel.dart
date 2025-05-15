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
      if (kDebugMode) {
        print("Failed to check if PDF is protected: '${e.message}'.");
      }
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
      if (kDebugMode) {
        print("Failed to open PDF: '${e.message}'.");
      }
      rethrow;
    }
  }

  @override
  Future<String?> getPdfAsBase64({
    required String filePath,
    required String password,
  }) async {
    try {
      final String? base64String = await methodChannel.invokeMethod(
        'getPdfAsBase64',
        {'filePath': filePath, 'password': password},
      );
      return base64String;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to get PDF as Base64: '${e.message}'.");
      }
      rethrow;
    }
  }
}
