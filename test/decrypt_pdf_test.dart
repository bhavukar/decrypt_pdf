import 'package:decrypt_pdf/decrypt_pdf.dart';
import 'package:decrypt_pdf/decrypt_pdf_method_channel.dart';
import 'package:decrypt_pdf/decrypt_pdf_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDecryptPdfPlatform
    with MockPlatformInterfaceMixin
    implements DecryptPdfPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> isPdfProtected({required String filePath}) {
    return Future.value(true);
  }

  @override
  Future<String?> openPdf({
    required String filePath,
    required String password,
  }) {
    return Future.value('mock_decrypted_path');
  }
}

void main() {
  final DecryptPdfPlatform initialPlatform = DecryptPdfPlatform.instance;

  test('$MethodChannelDecryptPdf is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDecryptPdf>());
  });

  test('getPlatformVersion', () async {
    // Set up mock platform before creating plugin instance
    MockDecryptPdfPlatform fakePlatform = MockDecryptPdfPlatform();
    DecryptPdfPlatform.instance = fakePlatform;

    // Use static method directly from DecryptPdf class
    expect(await DecryptPdf.getPlatformVersion(), '42');
  });
}
