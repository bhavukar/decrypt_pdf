import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'decrypt_pdf_platform_interface.dart';
// Conditionally import Windows implementation
import 'decrypt_pdf_windows.dart'
    if (dart.library.io) 'decrypt_pdf_windows.dart';

class DecryptPdf {
  static void registerWith() {
    if (kIsWeb) {
      // Web registration happens in web file
    } else if (Platform.isWindows) {
      DecryptPdfWindows.registerWith();
    }
  }

  static Future<String?> getPlatformVersion() {
    return DecryptPdfPlatform.instance.getPlatformVersion();
  }

  static Future<bool> isPdfProtected({required String filePath}) {
    return DecryptPdfPlatform.instance.isPdfProtected(filePath: filePath);
  }

  static Future<String?> openPdf({
    required String filePath,
    required String password,
  }) {
    return DecryptPdfPlatform.instance.openPdf(
      filePath: filePath,
      password: password,
    );
  }
}
