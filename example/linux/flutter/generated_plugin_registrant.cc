//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <decrypt_pdf/decrypt_pdf_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) decrypt_pdf_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "DecryptPdfPlugin");
  decrypt_pdf_plugin_register_with_registrar(decrypt_pdf_registrar);
}
