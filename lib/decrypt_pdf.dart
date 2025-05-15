import 'dart:async';

import 'decrypt_pdf_platform_interface.dart';

class DecryptPdf {
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

  //get getPdfAsBase64
  static Future<String?> getPdfAsBase64({
    required String filePath,
    required String password,
  }) {
    return DecryptPdfPlatform.instance.getPdfAsBase64(
      filePath: filePath,
      password: password,
    );
  }
}
