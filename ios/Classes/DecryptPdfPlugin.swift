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
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing filePath or password", details: nil))
        return
      }

      if let decryptedPath = Self.decryptPdf(at: filePath, password: password) {
        result(decryptedPath)
      } else {
        result(FlutterError(code: "DECRYPTION_FAILED", message: "Could not decrypt PDF", details: nil))
      }

    case "getPdfAsBase64":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String,
            let password = args["password"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path or password is null or invalid type", details: nil))
        return
      }

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

        if let pdfData = pdfDocument.dataRepresentation() {
          let base64String = pdfData.base64EncodedString()
          DispatchQueue.main.async {
            result(base64String)
          }
        } else {
          DispatchQueue.main.async {
            result(FlutterError(code: "DATA_CONVERSION_FAILED", message: "Failed to get data representation of PDF", details: nil))
          }
        }
      }

    case "isPdfProtected":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "File path is null or invalid type for isPdfProtected", details: nil))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        let fileURL = URL(fileURLWithPath: filePath)
        guard let pdfDocument = PDFDocument(url: fileURL) else {
          DispatchQueue.main.async {
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

  static func decryptPdf(at path: String, password: String) -> String? {
    guard let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) else {
      print("Failed to create PDFDocument")
      return nil
    }

    if pdfDocument.isEncrypted {
      let success = pdfDocument.unlock(withPassword: password)
      if !success {
        print("Incorrect password")
        return nil
      }
    }

    let newPdf = PDFDocument()
    for pageIndex in 0..<pdfDocument.pageCount {
      if let page = pdfDocument.page(at: pageIndex) {
        newPdf.insert(page, at: newPdf.pageCount)
      }
    }

    let tempDir = FileManager.default.temporaryDirectory
    let outputPath = tempDir.appendingPathComponent("decrypted_\(UUID().uuidString).pdf")

    if newPdf.write(to: outputPath) {
      print("Successfully wrote decrypted PDF to: \(outputPath.path)")
      return outputPath.path
    } else {
      print("Failed to write decrypted PDF")
      return nil
    }
  }
}
