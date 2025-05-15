// lib/decrypt_pdf_web.dart
import 'dart:async';
import 'dart:html'
    as html; // For File, FileReader, Blob, Url.createObjectUrlFromBlob
import 'dart:js_util' as js_util;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'decrypt_pdf_platform_interface.dart';

class DecryptPdfWeb extends DecryptPdfPlatform {
  static void registerWith(Registrar registrar) {
    DecryptPdfPlatform.instance = DecryptPdfWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'Web ${DateTime.now().toIso8601String()}';
  }

  @override
  Future<bool> isPdfProtected({
    required String filePath, // filePath is less relevant on web
    html.File? webFile, // This should be passed from file_picker on web
  }) async {
    if (webFile == null) {
      throw PlatformException(
        code: "MISSING_FILE_WEB",
        message: "Web file data not provided for isPdfProtected.",
      );
    }
    print('[Web] isPdfProtected called for ${webFile.name}');

    final completer = Completer<bool>();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(webFile);

    reader.onLoadEnd.listen((event) async {
      if (reader.readyState == html.FileReader.DONE) {
        final Uint8List fileBytes = reader.result as Uint8List;
        print(
          '[Web] isPdfProtected: File read, ${fileBytes.lengthInBytes} bytes.',
        );
        try {
          // Call a JavaScript function that uses PDF.js to check protection
          final jsPromise = js_util.callMethod(
            html.window,
            '_webIsPdfProtected',
            [fileBytes],
          );
          final bool isProtected = await js_util.promiseToFuture(
            jsPromise as Object,
          );
          print('[Web] isPdfProtected: Result from JS: $isProtected');
          completer.complete(isProtected);
        } catch (e) {
          print('[Web] isPdfProtected: Error during JS call: ${e.toString()}');
          completer.completeError(
            PlatformException(
              code: 'WEB_JS_CALL_ERROR_CHECK',
              message:
                  'Error calling PDF.js interop for isPdfProtected: ${e.toString()}',
            ),
          );
        }
      } else {
        print('[Web] isPdfProtected: FileReader not DONE.');
        completer.completeError(
          PlatformException(
            code: 'WEB_FILE_READ_INCOMPLETE_CHECK',
            message: 'Web file reading was not completed for isPdfProtected.',
          ),
        );
      }
    });
    reader.onError.listen((event) {
      print('[Web] isPdfProtected: FileReader error.');
      completer.completeError(
        PlatformException(
          code: 'WEB_FILE_READ_ERROR_CHECK',
          message: 'Error reading web file for isPdfProtected.',
        ),
      );
    });
    return completer.future;
  }

  @override
  Future<String?> openPdf({
    required String
    filePath, // filePath is less relevant on web, we need the actual file bytes
    required String password,
    html.File? webFile, // This should be passed from file_picker on web
  }) async {
    if (webFile == null) {
      throw PlatformException(
        code: "MISSING_FILE_WEB",
        message: "Web file data not provided for openPdf.",
      );
    }
    print('[Web] openPdf called for ${webFile.name}');

    final completer = Completer<String?>();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(webFile); // Read file as ArrayBuffer

    reader.onLoadEnd.listen((event) async {
      if (reader.readyState == html.FileReader.DONE) {
        final Uint8List fileBytes = reader.result as Uint8List;
        print(
          '[Web] openPdf: File read, ${fileBytes.lengthInBytes} bytes. Password: "$password"',
        );
        try {
          // Call a JavaScript function that uses PDF.js
          // This JS function will take fileBytes and password,
          // and return a Blob URL of the (potentially decrypted) PDF.
          final jsPromise = js_util.callMethod(
            html.window,
            '_webDecryptPdfToBlobUrl',
            [fileBytes, password],
          );
          final String? blobUrl = await js_util.promiseToFuture(
            jsPromise as Object,
          );
          if (blobUrl != null) {
            print('[Web] openPdf: Success, Blob URL: $blobUrl');
            completer.complete(blobUrl);
          } else {
            print('[Web] openPdf: Failed, JS returned null Blob URL.');
            completer.completeError(
              PlatformException(
                code: 'WEB_DECRYPTION_FAILED',
                message: 'PDF.js processing failed to return a Blob URL.',
              ),
            );
          }
        } catch (e) {
          print('[Web] openPdf: Error during JS call: ${e.toString()}');
          completer.completeError(
            PlatformException(
              code: 'WEB_JS_CALL_ERROR',
              message:
                  'Error calling PDF.js interop for openPdf: ${e.toString()}',
            ),
          );
        }
      } else {
        print('[Web] openPdf: FileReader not DONE.');
        completer.completeError(
          PlatformException(
            code: 'WEB_FILE_READ_INCOMPLETE',
            message: 'Web file reading was not completed.',
          ),
        );
      }
    });

    reader.onError.listen((event) {
      print('[Web] openPdf: FileReader error.');
      completer.completeError(
        PlatformException(
          code: 'WEB_FILE_READ_ERROR',
          message: 'Error reading web file for openPdf.',
        ),
      );
    });

    return completer.future;
  }
}
