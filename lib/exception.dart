/// Base exception for all PDF-related errors
class PdfException implements Exception {
  final String? message;

  PdfException([this.message]);

  @override
  String toString() => 'PdfException: $message';
}

/// Exception thrown when the PDF file cannot be found
class PdfNotFoundException extends PdfException {
  PdfNotFoundException([String? message])
    : super(message ?? 'PDF file not found');
}

/// Exception thrown when an incorrect password is provided
class PdfInvalidPasswordException extends PdfException {
  PdfInvalidPasswordException([String? message])
    : super(message ?? 'Invalid PDF password');
}

/// Exception thrown when the PDF file is corrupted
class PdfCorruptedException extends PdfException {
  PdfCorruptedException([String? message])
    : super(message ?? 'PDF file is corrupted');
}

/// Exception thrown when the PDF encryption is not supported
class PdfUnsupportedEncryptionException extends PdfException {
  PdfUnsupportedEncryptionException([String? message])
    : super(message ?? 'PDF encryption type is not supported');
}

/// Exception thrown when there is not enough memory to process the PDF
class PdfOutOfMemoryException extends PdfException {
  PdfOutOfMemoryException([String? message])
    : super(message ?? 'Not enough memory to process the PDF');
}
