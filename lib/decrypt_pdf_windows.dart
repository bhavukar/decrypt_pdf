// lib/decrypt_pdf_windows.dart
import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';

import 'decrypt_pdf_platform_interface.dart';

class DecryptPdfWindows extends DecryptPdfPlatform {
  static void registerWith() {
    DecryptPdfPlatform.instance = DecryptPdfWindows();
  }

  @override
  Future<String?> getPlatformVersion() async {
    try {
      final osVersionInfo = calloc<OSVERSIONINFO>();
      osVersionInfo.ref.dwOSVersionInfoSize = sizeOf<OSVERSIONINFO>();

      final result = GetVersionEx(osVersionInfo);

      if (result != 0) {
        final version =
            'Windows ${osVersionInfo.ref.dwMajorVersion}.${osVersionInfo.ref.dwMinorVersion} (Build ${osVersionInfo.ref.dwBuildNumber})';
        free(osVersionInfo);
        return version;
      }

      free(osVersionInfo);
      return 'Windows (version unknown)';
    } catch (e) {
      return 'Windows (error getting version)';
    }
  }

  @override
  Future<bool> isPdfProtected({required String filePath}) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return false;
      }

      // Simple check for PDF header
      final bytes = await file.openRead(0, 1024).toList();
      final data = bytes.expand((x) => x).toList();
      final content = String.fromCharCodes(data);

      // Look for encryption dictionary in PDF
      // This is a simple check - not comprehensive
      if (content.contains('/Encrypt') || content.contains('/Encrypt ')) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error checking PDF protection: $e');
      return false;
    }
  }

  @override
  Future<String?> openPdf({
    required String filePath,
    required String password,
  }) async {
    try {
      // Using Win32 API to get the temp path
      final tempPathPointer = calloc<Uint16>(MAX_PATH).cast<Utf16>();
      final length = GetTempPath(MAX_PATH, tempPathPointer);

      if (length == 0) {
        final error = GetLastError();
        calloc.free(tempPathPointer);
        throw WindowsException(error);
      }

      // Convert to Dart string and free memory
      final tempDirPath = tempPathPointer.toDartString();
      calloc.free(tempPathPointer);

      // Create a unique filename for the output
      final inputFile = File(filePath);
      final originalFilename = path.basename(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFilename = 'decrypted_${timestamp}_$originalFilename';
      final outputPath = path.join(tempDirPath, outputFilename);

      // For now, we'll just copy the file since we don't have PDF decryption
      // implemented directly in Dart. In a real implementation, you would
      // use a PDF library or call to native code to perform the decryption.
      await inputFile.copy(outputPath);

      return outputPath;
    } catch (e) {
      print('Error opening PDF: $e');
      return null;
    }
  }
}

class WindowsException implements Exception {
  final int code;
  String get message {
    final messageBuffer = calloc<Uint16>(1024).cast<Utf16>();
    try {
      final length = FormatMessage(
        FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        nullptr,
        code,
        0,
        messageBuffer,
        1024,
        nullptr,
      );

      if (length == 0) return 'Error code: $code';
      return messageBuffer.toDartString();
    } finally {
      calloc.free(messageBuffer);
    }
  }

  WindowsException(this.code);

  @override
  String toString() => 'Windows Error ($code): $message';
}
