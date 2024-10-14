function previewFile(url) {
    window.webkit.messageHandlers.previewFile.postMessage(url);
}

function downloadFile(url) {
    window.webkit.messageHandlers.downloadFile.postMessage(url);
}
