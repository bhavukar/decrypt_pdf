#include "include/decrypt_pdf/decrypt_pdf_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "decrypt_pdf_plugin.h"

void DecryptPdfPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  decrypt_pdf::DecryptPdfPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
