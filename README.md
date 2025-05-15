# Decrypt PDF (`decrypt_pdf`)

A Flutter plugin to handle password-protected PDF files. Allows checking if a PDF is protected, opening/decrypting it to a temporary file path, and retrieving the PDF content as a Base64 encoded string.

Currently supports **Android** and **iOS**.

## Features

* Check if a PDF file is password-protected.
* Open a password-protected PDF by providing the password, saving a decrypted version to a temporary file.
* Get the content of a (potentially password-protected) PDF as a Base64 encoded string.

## Getting Started


### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  decrypt_pdf: ^0.0.1 # Replace with the actual version you publish



Then, run flutter pub get.
Platform Support
| Platform | Supported | Notes |
| Android | ✅ | Uses com.tom_roush:pdfbox-android |
| iOS | ✅ | Uses PDFKit (page copying method) |
| Web | 🚧 | Planned for future release |
| Linux | 🚧 | Planned for future release |
| macOS | 🚧 | Planned for future release |
| Windows | 🚧 | Planned for future release |

Usage
Import the package:
import 'package:decrypt_pdf/decrypt_pdf.dart';
import 'package:file_picker/file_picker.dart'; // For picking files
// You'll also need a PDF viewer plugin, e.g., pdfx, to display the decrypted PDF.



Core Methods
1. Check if PDF is Protected
Future<void> checkIfProtected(String filePath) async {
  try {
    bool isProtected = await DecryptPdf.isPdfProtected(filePath: filePath);
    if (isProtected) {
      print('PDF is password protected.');
      // Prompt user for password
    } else {
      print('PDF is not password protected.');
      // Open directly or using openPdf with an empty password
    }
  } catch (e) {
    print('Error checking PDF protection: $e');
  }
}



2. Open/Decrypt PDF to a File Path
This method decrypts the PDF (if password-protected and correct password supplied) and saves it to a temporary file. It returns the path to this temporary, decrypted file.
Future<String?> getDecryptedPdfPath(String pickedFilePath, String password) async {
  try {
    print('Attempting to open/decrypt PDF: $pickedFilePath');
    // If the PDF is not password-protected, pass an empty string for the password.
    // The native implementations should handle this gracefully.
    String? decryptedPath = await DecryptPdf.openPdf(
      filePath: pickedFilePath,
      password: password, // Use empty string "" if not protected
    );

    if (decryptedPath != null) {
      print('PDF processed. Decrypted path: $decryptedPath');
      // You can now use this path with a PDF viewer plugin
      // e.g., Navigator.push(context, MaterialPageRoute(builder: (_) => PDFScreen(path: decryptedPath)));
      return decryptedPath;
    } else {
      print('Failed to get decrypted PDF path (returned null).');
      return null;
    }
  } catch (e) {
    print('Error opening/decrypting PDF: $e');
    // Handle specific errors, e.g., invalid password
    if (e is PlatformException && e.code == 'INVALID_PASSWORD') {
      print('The password provided was incorrect.');
    }
    return null;
  }
}



3. Get PDF Content as Base64
This method returns the PDF content as a Base64 encoded string. This can be useful for displaying PDFs in web views that support data URIs, or for transmitting PDF data.
Future<String?> getPdfAsBase64String(String pickedFilePath, String password) async {
  try {
    print('Attempting to get PDF as Base64: $pickedFilePath');
    String? base64String = await DecryptPdf.getPdfAsBase64(
      filePath: pickedFilePath,
      password: password, // Use empty string "" if not protected
    );

    if (base64String != null) {
      print('Successfully retrieved PDF as Base64 string (length: ${base64String.length}).');
      // Example: display in a WebView that supports PDF data URI
      // final String dataUri = 'data:application/pdf;base64,$base64String';
      return base64String;
    } else {
      print('Failed to get PDF as Base64 (returned null).');
      return null;
    }
  } catch (e) {
    print('Error getting PDF as Base64: $e');
    if (e is PlatformException && e.code == 'INVALID_PASSWORD') {
      print('The password provided was incorrect for Base64 conversion.');
    }
    return null;
  }
}
```




Contributions
Contributions are welcome! Please feel free to submit a Pull Request.

License
This project is licensed under the MIT License. See the LICENSE file for details.


