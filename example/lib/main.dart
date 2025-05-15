import 'dart:async';

import 'package:decrypt_pdf/decrypt_pdf.dart'; // Import your plugin
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _pickedFilePath;
  String? _decryptedPdfPath;
  String _status = 'Please pick a PDF file.';
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _status = 'Picking file...';
      _decryptedPdfPath = null; // Reset on new file pick
      _pickedFilePath = null;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        _pickedFilePath = result.files.single.path!;
        _status = 'File picked: ${_pickedFilePath!.split('/').last}';
        // Automatically try to check if it's protected
        await _checkAndPromptForPassword();
      } else {
        _status = 'File picking cancelled.';
      }
    } catch (e) {
      _status = 'Error picking file: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndPromptForPassword() async {
    if (_pickedFilePath == null) return;

    setState(() {
      _isLoading = true;
      _status = 'Checking if PDF is protected...';
    });

    try {
      bool isProtected = await DecryptPdf.isPdfProtected(
        filePath: _pickedFilePath!,
      );
      if (isProtected) {
        _status = 'PDF is password protected. Please enter password.';
        // ignore: use_build_context_synchronously
        _showPasswordDialog(); // Show dialog to get password
      } else {
        _status = 'PDF is not protected. Opening directly...';
        // If not protected, we can try to "open" it with an empty password
        // or directly use the original path with PDFView if it supports it.
        // For consistency with the plugin's flow, let's still use 'openPdf'.
        // The native side should handle non-protected PDFs gracefully.
        await _openPdfWithPassword(""); // Treat as opening with empty password
      }
    } catch (e) {
      _status = 'Error checking PDF protection: $e';
      // If checking fails, still allow user to try opening with password
      _showPasswordDialog();
    } finally {
      // isLoading will be set to false inside _showPasswordDialog or _openPdfWithPassword
    }
  }

  Future<void> _showPasswordDialog() async {
    // Reset loading state if it was set by _checkAndPromptForPassword
    // as the dialog itself is an interaction point.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (_pickedFilePath == null) return;

    _passwordController.clear(); // Clear previous password
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must enter password or cancel
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter PDF Password'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Password'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _status = 'Password entry cancelled.';
                });
              },
            ),
            TextButton(
              child: const Text('Open'),
              onPressed: () {
                Navigator.of(context).pop();
                _openPdfWithPassword(_passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPdfWithPassword(String password) async {
    if (_pickedFilePath == null) {
      setState(() {
        _status = 'No file picked to open.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Attempting to open PDF...';
      _decryptedPdfPath = null;
    });

    try {
      final String? tempPath = await DecryptPdf.openPdf(
        filePath: _pickedFilePath!,
        password: password,
      );

      if (tempPath != null) {
        _decryptedPdfPath = tempPath;
        _status = 'PDF decrypted successfully! Path: $tempPath';
      } else {
        // This case might not happen if openPdf throws exceptions for failures
        _status = 'Failed to decrypt PDF. Temp path is null.';
      }
    } catch (e) {
      _status = 'Error opening PDF: $e';
      // If it's an invalid password, you might want to prompt again
      // For example, check e.code or e.message
      if (e.toString().toLowerCase().contains("invalid_password")) {
        _status = 'Incorrect password. Please try again.';
        // Optionally, re-show password dialog
        // _showPasswordDialog();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up temporary files if any were created and you want to manage them
    // For this example, cache files are usually managed by the OS.
    // If you create files in a persistent location, manage them here.
    // For example:
    // if (_decryptedPdfPath != null) {
    //   try {
    //     File(_decryptedPdfPath!).delete();
    //   } catch (e) {
    //     print("Error deleting temp file: $e");
    //   }
    // }
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading == true ? LinearProgressIndicator() : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.file_open),
                label: const Text('Pick Encrypted PDF'),
                onPressed: _isLoading ? null : _pickFile,
              ),
              const SizedBox(height: 20),

              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              if (_pickedFilePath != null &&
                  !_isLoading &&
                  _decryptedPdfPath == null &&
                  !_status.contains("PDF is not protected"))
                ElevatedButton(
                  onPressed: _showPasswordDialog,
                  child: const Text('Enter Password & Open'),
                ),
              const SizedBox(height: 20),
              if (_decryptedPdfPath != null && !_isLoading)
                Expanded(
                  child: PdfView(
                    controller: PdfController(
                      document: PdfDocument.openFile(_decryptedPdfPath!),
                      initialPage: 0,
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
