import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Opens the system print dialog so the user can pick AirPrint or a saved printer.
class PrintService {
  Future<void> printImages(
    List<Uint8List> pages, {
    required String name,
  }) async {
    if (pages.isEmpty) return;
    await Printing.layoutPdf(
      name: name,
      onLayout: (format) async {
        final doc = pw.Document();
        for (final bytes in pages) {
          final image = pw.MemoryImage(bytes);
          doc.addPage(
            pw.Page(
              pageFormat: format,
              margin: const pw.EdgeInsets.all(28),
              build: (_) => pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
          );
        }
        return doc.save();
      },
    );
  }
}
