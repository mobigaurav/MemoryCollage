import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Opens the system print dialog so the user can pick AirPrint or a saved printer.
class PrintService {
  Future<Uint8List> pdfFromImages(List<Uint8List> pages) async {
    final doc = pw.Document();
    for (final bytes in pages) {
      final image = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }
    return doc.save();
  }

  Future<void> printImages(
    List<Uint8List> pages, {
    required String name,
    double? pageWidthInches,
    double? pageHeightInches,
  }) async {
    if (pages.isEmpty) return;
    final paper = pageWidthInches == null || pageHeightInches == null
        ? null
        : PdfPageFormat(pageWidthInches * 72, pageHeightInches * 72);
    await Printing.layoutPdf(
      name: name,
      onLayout: (format) async {
        final doc = pw.Document();
        final page = paper ?? format;
        for (final bytes in pages) {
          final image = pw.MemoryImage(bytes);
          doc.addPage(
            pw.Page(
              pageFormat: page,
              margin: pw.EdgeInsets.all(paper == null ? 28 : 0),
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
