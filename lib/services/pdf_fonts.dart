import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Reusable PDF font bundle with embedded Unicode Kannada fonts.
class PdfFonts {
  const PdfFonts({
    required this.kannadaRegular,
    required this.kannadaBold,
    this.baseRegular,
    this.baseBold,
  });

  final pw.Font kannadaRegular;
  final pw.Font kannadaBold;
  final pw.Font? baseRegular;
  final pw.Font? baseBold;

  static PdfFonts? _cached;

  /// Loads Kannada regular and bold TrueType fonts from bundled assets.
  /// Reuses cached instances to avoid reloading font bytes multiple times.
  static Future<PdfFonts> load() async {
    if (_cached != null) return _cached!;

    ByteData regularData;
    ByteData boldData;

    try {
      regularData = await rootBundle.load(
        'assets/fonts/NotoSansKannada-Regular.ttf',
      );
      boldData = await rootBundle.load(
        'assets/fonts/NotoSansKannada-Bold.ttf',
      );
    } catch (_) {
      final regFile = File('assets/fonts/NotoSansKannada-Regular.ttf');
      final boldFile = File('assets/fonts/NotoSansKannada-Bold.ttf');
      if (regFile.existsSync() && boldFile.existsSync()) {
        final regBytes = await regFile.readAsBytes();
        final boldBytes = await boldFile.readAsBytes();
        regularData = regBytes.buffer.asByteData();
        boldData = boldBytes.buffer.asByteData();
      } else {
        rethrow;
      }
    }

    _cached = PdfFonts(
      kannadaRegular: pw.Font.ttf(regularData),
      kannadaBold: pw.Font.ttf(boldData),
      baseRegular: pw.Font.helvetica(),
      baseBold: pw.Font.helveticaBold(),
    );
    return _cached!;
  }

  /// Clears cached fonts (primarily useful in unit tests).
  static void resetCache() {
    _cached = null;
  }
}
