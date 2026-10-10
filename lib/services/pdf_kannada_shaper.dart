import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/category_seed.dart';
import '../models/catering_list.dart';
import '../models/user.dart';
import 'pdf_fonts.dart';

/// HarfBuzz-backed complex-script shaper for Kannada text in PDF generation.
/// Uses Flutter's native text shaper (Skia/Impeller HarfBuzz engine) to accurately
/// form Kannada conjuncts, vowel signs, and consonant clusters (GSUB/GPOS).
/// Renders crisp high-resolution glyphs with an invisible Unicode text layer
/// to ensure searchability and text copyability.
class PdfKannadaShaper {
  static bool _fontLoaded = false;
  static final RegExp _kannadaRegex = RegExp(r'[\u0C80-\u0CFF]');

  // In-memory cache for rendered shaped text snippets: key -> (pngBytes, unscaledWidth, unscaledHeight)
  static final Map<String, (Uint8List, double, double)> _cache = {};

  static bool hasKannada(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    return _kannadaRegex.hasMatch(text);
  }

  /// Ensures Noto Sans Kannada fonts are registered in the Flutter engine.
  static Future<void> ensureInitialized() async {
    if (_fontLoaded) return;
    try {
      final fontLoader = FontLoader('NotoSansKannada');
      fontLoader.addFont(rootBundle.load('assets/fonts/NotoSansKannada-Regular.ttf'));
      fontLoader.addFont(rootBundle.load('assets/fonts/NotoSansKannada-Bold.ttf'));
      await fontLoader.load();
    } catch (_) {
      // Font might already be registered in pubspec or previous load
    }
    _fontLoaded = true;
  }

  static String _cacheKey(String text, double fontSize, PdfColor color, bool isBold, double scale) {
    return '$text|${fontSize.toStringAsFixed(1)}|${color.toInt()}|$isBold|${scale.toStringAsFixed(1)}';
  }

  /// Shapes a single Kannada text snippet at high DPI (default 3.5x).
  static Future<void> preShapeSnippet(
    String text, {
    required double fontSize,
    required PdfColor color,
    bool isBold = false,
    double scale = 3.5,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final key = _cacheKey(trimmed, fontSize, color, isBold, scale);
    if (_cache.containsKey(key)) return;

    await ensureInitialized();

    final flutterColor = Color(color.toInt());
    final textPainter = TextPainter(
      text: TextSpan(
        text: trimmed,
        style: TextStyle(
          fontFamily: 'NotoSansKannada',
          fontSize: fontSize * scale,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: flutterColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final pixelWidth = textPainter.width.ceil().clamp(1, 8192);
    final pixelHeight = textPainter.height.ceil().clamp(1, 8192);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    textPainter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(pixelWidth, pixelHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      final unscaledWidth = textPainter.width / scale;
      final unscaledHeight = textPainter.height / scale;
      _cache[key] = (byteData.buffer.asUint8List(), unscaledWidth, unscaledHeight);
    }
  }

  /// Pre-shapes all Kannada content present in the catering list and business profile.
  /// Must be called before generating MultiPage to enable synchronous layout.
  static Future<void> preShapeAll({
    required CateringList list,
    required BusinessProfile profile,
    required PdfColor primaryColor,
    required PdfColor secondaryColor,
    required PdfColor accentColor,
    required PdfColor textDark,
    required PdfColor textMuted,
  }) async {
    await ensureInitialized();

    final futures = <Future<void>>[];

    // 1. Header Badge
    futures.add(preShapeSnippet(
      'ಅಡುಗೆ ಸಾಮಾನುಗಳ ಪಟ್ಟಿ',
      fontSize: 8.5,
      color: const PdfColor.fromInt(0xFFFFF0DE),
      isBold: true,
    ));

    // 2. Business Tagline
    if (hasKannada(profile.tagline)) {
      futures.add(preShapeSnippet(
        profile.tagline!.replaceAll('•', '—'),
        fontSize: 9,
        color: textMuted,
        isBold: false,
      ));
    }

    // 3. Client/Event Summary fields
    if (hasKannada(list.eventName)) {
      futures.add(preShapeSnippet(
        list.eventName,
        fontSize: 14,
        color: primaryColor,
        isBold: true,
      ));
    }
    if (hasKannada(list.clientName)) {
      futures.add(preShapeSnippet(
        list.clientName,
        fontSize: 10.5,
        color: textDark,
        isBold: false,
      ));
    }
    if (hasKannada(list.location)) {
      futures.add(preShapeSnippet(
        list.location!,
        fontSize: 9.5,
        color: textMuted,
        isBold: false,
      ));
    }
    if (hasKannada(list.notes)) {
      futures.add(preShapeSnippet(
        list.notes!,
        fontSize: 9.5,
        color: textMuted,
        isBold: false,
      ));
    }

    // Guest label Kannada word
    if (list.guestCount != null && list.guestCount! > 0) {
      futures.add(preShapeSnippet(
        'ಜನರಿಗೆ',
        fontSize: 10,
        color: accentColor,
        isBold: true,
      ));
    }

    // 4. Category Headings
    for (final catId in list.groupedByCategory.keys) {
      final cat = CategorySeed.getCategory(catId);
      if (hasKannada(cat.nameKannada)) {
        futures.add(preShapeSnippet(
          cat.nameKannada,
          fontSize: 10.5,
          color: primaryColor,
          isBold: true,
        ));
      }
    }

    // 5. Items
    for (final item in list.items) {
      if (hasKannada(item.nameKannada)) {
        futures.add(preShapeSnippet(
          item.nameKannada,
          fontSize: 10,
          color: textDark,
          isBold: true,
        ));
      }
      if (hasKannada(item.notes)) {
        futures.add(preShapeSnippet(
          item.notes!,
          fontSize: 8,
          color: accentColor,
          isBold: false,
        ));
      }
    }

    await Future.wait(futures);
  }

  /// Builds a pw.Widget for shaped Kannada text with an invisible Unicode layer for search/copy.
  static pw.Widget buildShapedText(
    String text, {
    required double fontSize,
    required PdfColor color,
    bool isBold = false,
    PdfFonts? fonts,
    double scale = 3.5,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return pw.SizedBox();

    final key = _cacheKey(trimmed, fontSize, color, isBold, scale);
    final cached = _cache[key];

    if (cached == null) {
      // Fallback if not pre-rendered
      return pw.Text(
        trimmed,
        style: pw.TextStyle(
          font: fonts != null
              ? (isBold ? fonts.kannadaBold : fonts.kannadaRegular)
              : null,
          fontSize: fontSize,
          color: color,
        ),
      );
    }

    final imageWidget = pw.Image(
      pw.MemoryImage(cached.$1),
      width: cached.$2,
      height: cached.$3,
      fit: pw.BoxFit.contain,
    );

    if (fonts != null) {
      return pw.Stack(
        alignment: pw.Alignment.topLeft,
        children: [
          pw.Opacity(
            opacity: 0.0,
            child: pw.Text(
              trimmed,
              style: pw.TextStyle(
                font: isBold ? fonts.kannadaBold : fonts.kannadaRegular,
                fontFallback: [pw.Font.helvetica(), pw.Font.helveticaBold()],
                fontSize: fontSize,
              ),
            ),
          ),
          imageWidget,
        ],
      );
    }

    return imageWidget;
  }

  /// Clears the shaper cache.
  static void clearCache() {
    _cache.clear();
  }
}
