async function _webIsPdfProtected(uint8ArrayData) {
    console.log("[JS] _webIsPdfProtected called");
    try {
        const loadingTask = pdfjsLib.getDocument({ data: uint8ArrayData });
        // PDF.js calls onPassword if a password is needed.
        // If it loads without needing a password, it's not protected (or password was empty).
        // If it fails for other reasons, it might also not be "protected" in the password sense.
        let isProtected = false;
        loadingTask.onPassword = (updatePassword, reason) => {
            console.log("[JS] _webIsPdfProtected: onPassword callback triggered. Reason:", reason);
            // PDFJS.PasswordResponses.NEED_PASSWORD = 1;
            // PDFJS.PasswordResponses.INCORRECT_PASSWORD = 2;
            if (reason === 1 || reason === 2) {
                isProtected = true;
            }
            // We don't provide a password here, just checking.
            // To prevent an error/prompt, we can try to "cancel" by not calling updatePassword.
            // However, the promise might still reject.
        };

        await loadingTask.promise;
        console.log("[JS] _webIsPdfProtected: Document loaded without password prompt (or onPassword handled it). Returning:", isProtected);
        return isProtected; // If it loads successfully without onPassword being an issue, it's not protected.
    } catch (error) {
        console.warn("[JS] _webIsPdfProtected: Error during getDocument:", error);
        if (error.name === 'PasswordException' || (error.message && error.message.toLowerCase().includes('password'))) {
            console.log("[JS] _webIsPdfProtected: PasswordException or similar, indicating protection. Returning true.");
            return true;
        }
        // For other errors (e.g., invalid PDF), consider it not "password protected" for this check's purpose.
        console.log("[JS] _webIsPdfProtected: Other error, assuming not password protected. Returning false.");
        return false;
    }
}

/**
 * Decrypts a PDF using PDF.js and returns a Blob URL.
 * @param {Uint8Array} uint8ArrayData The PDF data.
 * @param {string} password The password for the PDF (can be empty).
 * @returns {Promise<string|null>} A Blob URL for the decrypted PDF, or null on failure.
 */
async function _webDecryptPdfToBlobUrl(uint8ArrayData, password) {
    console.log("[JS] _webDecryptPdfToBlobUrl called. Password:", password === "" ? "(empty)" : "(provided)");
    try {
        const loadingTask = pdfjsLib.getDocument({
            data: uint8ArrayData,
            password: password, // Provide the password
        });

        const pdfDocumentProxy = await loadingTask.promise;
        console.log("[JS] _webDecryptPdfToBlobUrl: PDF loaded/unlocked. Num pages:", pdfDocumentProxy.numPages);

        // To get a "clean" representation, we try to save the document.
        // The saveDocument() method returns a Promise that resolves with a Uint8Array.
        const decryptedPdfBytes = await pdfDocumentProxy.saveDocument();
        console.log("[JS] _webDecryptPdfToBlobUrl: saveDocument() successful, got bytes:", decryptedPdfBytes.length);

        const blob = new Blob([decryptedPdfBytes], { type: 'application/pdf' });
        const blobUrl = URL.createObjectURL(blob);
        console.log("[JS] _webDecryptPdfToBlobUrl: Created Blob URL:", blobUrl);
        return blobUrl;

    } catch (error) {
        console.error("[JS] _webDecryptPdfToBlobUrl: Error processing PDF:", error);
        if (error.name === 'PasswordException' || (error.message && error.message.toLowerCase().includes('password'))) {
            console.error("[JS] _webDecryptPdfToBlobUrl: Password incorrect or required.");
        }
        return null; // Indicate failure
    }
}

/**
 * Decrypts a PDF using PDF.js and returns its bytes as a Uint8Array.
 * @param {Uint8Array} uint8ArrayData The PDF data.
 * @param {string} password The password for the PDF (can be empty).
 * @returns {Promise<Uint8Array|null>} Uint8Array of the decrypted PDF, or null on failure.
 */
async function _webGetDecryptedPdfBytes(uint8ArrayData, password) {
    console.log("[JS] _webGetDecryptedPdfBytes called. Password:", password === "" ? "(empty)" : "(provided)");
    try {
        const loadingTask = pdfjsLib.getDocument({
            data: uint8ArrayData,
            password: password,
        });

        const pdfDocumentProxy = await loadingTask.promise;
        console.log("[JS] _webGetDecryptedPdfBytes: PDF loaded/unlocked. Num pages:", pdfDocumentProxy.numPages);

        // The saveDocument() method returns a Promise that resolves with a Uint8Array.
        // This is the most likely way PDF.js provides the "cleaned" or "reconstructed" document bytes.
        const decryptedPdfBytes = await pdfDocumentProxy.saveDocument();
        console.log("[JS] _webGetDecryptedPdfBytes: saveDocument() successful, got bytes:", decryptedPdfBytes.length);
        return decryptedPdfBytes;

    } catch (error) {
        console.error("[JS] _webGetDecryptedPdfBytes: Error processing PDF:", error);
        if (error.name === 'PasswordException' || (error.message && error.message.toLowerCase().includes('password'))) {
            console.error("[JS] _webGetDecryptedPdfBytes: Password incorrect or required.");
        }
        return null; // Indicate failure
    }
}

// Make these functions available on the window object for Dart to call
window._webIsPdfProtected = _webIsPdfProtected;
window._webDecryptPdfToBlobUrl = _webDecryptPdfToBlobUrl;
window._webGetDecryptedPdfBytes = _webGetDecryptedPdfBytes;

console.log("[JS] PDF Interop functions registered on window object.");
