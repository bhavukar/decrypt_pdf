import Flutter
import UIKit
import PDFKit

public class DecryptPdfPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "decrypt_pdf", binaryMessenger: registrar.messenger())
    let instance = DecryptPdfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
 case "openPdf":
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String,
              let password = args["password"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path or password is null or invalid type", details: nil))
            return
        }

        // PDFKit operations can be intensive, dispatch to a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            let fileURL = URL(fileURLWithPath: filePath)

            guard let pdfDocument = PDFDocument(url: fileURL) else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "FILE_NOT_FOUND", message: "Could not create PDFDocument from URL: \(filePath)", details: nil))
                }
                return
            }

            if pdfDocument.isEncrypted {
                if !pdfDocument.unlock(withPassword: password) {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "INVALID_PASSWORD", message: "Incorrect password for PDF or failed to unlock.", details: nil))
                    }
                    return
                }
            }
            // If we reach here, the document is unlocked or was not encrypted.

            // Option: Save the (potentially decrypted) PDF to a temporary file.
            // This makes it easy to use with Flutter PDF viewer plugins that take a file path.
            let tempDirectoryURL = FileManager.default.temporaryDirectory
            let tempFilename = "decrypted_pdf_\(UUID().uuidString).pdf"
            let tempFileURL = tempDirectoryURL.appendingPathComponent(tempFilename)

            // Writing the PDFDocument object should save its current state (unlocked).
            if pdfDocument.write(to: tempFileURL) {
                DispatchQueue.main.async {
                    result(tempFileURL.path)
                }
            } else {
                DispatchQueue.main.async {
                    result(FlutterError(code: "SAVE_FAILED", message: "Could not save decrypted PDF to temporary file.", details: nil))
                }
            }
        }

    case "isPdfProtected":
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS_CHECK", message: "File path is null or invalid type for isPdfProtected", details: nil))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let fileURL = URL(fileURLWithPath: filePath)
            guard let pdfDocument = PDFDocument(url: fileURL) else {
                DispatchQueue.main.async {
                     // If it can't even be initialized, it might be corrupt or not a PDF,
                     // but we can't definitively say it's protected without trying to parse it.
                     // For simplicity, returning false, but you might want more robust error handling.
                    result(false)
                }
                return
            }
            DispatchQueue.main.async {
                result(pdfDocument.isEncrypted)
            }
        }


    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
