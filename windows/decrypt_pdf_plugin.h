#ifndef FLUTTER_PLUGIN_DECRYPT_PDF_PLUGIN_H_
#define FLUTTER_PLUGIN_DECRYPT_PDF_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace decrypt_pdf {

class DecryptPdfPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DecryptPdfPlugin();

  virtual ~DecryptPdfPlugin();

  // Disallow copy and assign.
  DecryptPdfPlugin(const DecryptPdfPlugin&) = delete;
  DecryptPdfPlugin& operator=(const DecryptPdfPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace decrypt_pdf

#endif  // FLUTTER_PLUGIN_DECRYPT_PDF_PLUGIN_H_
