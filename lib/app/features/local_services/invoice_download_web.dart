import 'dart:html' as html;
import 'dart:typed_data';

void downloadInvoiceBytes(Uint8List bytes, String filename) {
  final blob = html.Blob(<dynamic>[bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}
