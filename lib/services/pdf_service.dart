import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../core/utils/date_utils.dart';
import '../data/category_seed.dart';
import '../models/catering_list.dart';
import '../models/list_ingredient.dart';
import '../models/user.dart';
import 'pdf_fonts.dart';
import 'pdf_kannada_shaper.dart';

export 'pdf_fonts.dart';
export 'pdf_kannada_shaper.dart';

/// Service for generating high-quality bilingual PDF documents with HarfBuzz-shaped Kannada text.
class PdfService {
  const PdfService();

  static const PdfColor primaryColor = PdfColor.fromInt(0xFF123F35);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF2B6E5D);
  static const PdfColor accentColor = PdfColor.fromInt(0xFFE98D31);
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF6F6F2);
  static const PdfColor textDark = PdfColor.fromInt(0xFF152620);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF667B73);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFE0E4E2);

  /// Primary static entrypoint used by share and preview services.
  static Future<Uint8List> generateCateringListPdf({
    required CateringList list,
    required BusinessProfile profile,
  }) async {
    return const PdfService().generateIngredientListPdf(list, profile: profile);
  }

  /// Instance method matching specification lifecycle.
  Future<Uint8List> generateIngredientListPdf(
    CateringList list, {
    BusinessProfile? profile,
  }) async {
    final activeProfile = profile ?? BusinessProfile.defaultProfile();
    final pdf = pw.Document();

    // 1. Load embedded Kannada fonts (for fallback & invisible search layer)
    final fonts = await PdfFonts.load();

    // 2. Pre-shape all Kannada text runs using Flutter's native HarfBuzz engine
    await PdfKannadaShaper.preShapeAll(
      list: list,
      profile: activeProfile,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
      textDark: textDark,
      textMuted: textMuted,
    );

    // 3. Configure document theme with Kannada fallback
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      fontFallback: [
        fonts.kannadaRegular,
        fonts.kannadaBold,
      ],
    );

    // 4. MultiPage document layout
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(28),
        header: (_) => buildHeader(list, fonts, profile: activeProfile),
        footer: (context) => buildFooter(context, fonts),
        build: (_) => [
          buildClientSummary(list, fonts),
          pw.SizedBox(height: 12),
          buildSummaryStats(list),
          pw.SizedBox(height: 14),
          ...buildIngredientSections(list, fonts),
        ],
      ),
    );

    return pdf.save();
  }

  /// Builds document header with caterer branding and bilingual document title badge.
  static pw.Widget buildHeader(
    CateringList list,
    PdfFonts fonts, {
    BusinessProfile? profile,
  }) {
    final activeProfile = profile ?? BusinessProfile.defaultProfile();

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: primaryColor, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  activeProfile.businessName.toUpperCase(),
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 18,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                if (activeProfile.tagline != null &&
                    activeProfile.tagline!.trim().isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 2),
                    child: PdfKannadaShaper.hasKannada(activeProfile.tagline)
                        ? PdfKannadaShaper.buildShapedText(
                            activeProfile.tagline!.replaceAll('•', '—'),
                            fontSize: 9,
                            color: textMuted,
                            isBold: false,
                            fonts: fonts,
                          )
                        : pw.Text(
                            activeProfile.tagline!.replaceAll('•', '—'),
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: textMuted,
                            ),
                          ),
                  ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Phone: ${activeProfile.phone}${activeProfile.address != null && activeProfile.address!.trim().isNotEmpty ? "  |  ${activeProfile.address}" : ""}',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INGREDIENT LIST',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 10,
                    color: PdfColors.white,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 2),
                PdfKannadaShaper.buildShapedText(
                  'ಅಡುಗೆ ಸಾಮಾನುಗಳ ಪಟ್ಟಿ',
                  fontSize: 8.5,
                  color: const PdfColor.fromInt(0xFFFFF0DE),
                  isBold: true,
                  fonts: fonts,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds document footer with page number context.
  static pw.Widget buildFooter(
    pw.Context context,
    PdfFonts fonts,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated with CaterPrep — Paperless Catering Management',
            style: const pw.TextStyle(
              fontSize: 8,
              color: textMuted,
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds client and event summary box.
  static pw.Widget buildClientSummary(
    CateringList list,
    PdfFonts fonts,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: borderColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    PdfKannadaShaper.hasKannada(list.eventName)
                        ? PdfKannadaShaper.buildShapedText(
                            list.eventName,
                            fontSize: 14,
                            color: primaryColor,
                            isBold: true,
                            fonts: fonts,
                          )
                        : pw.Text(
                            list.eventName,
                            style: pw.TextStyle(
                              font: pw.Font.helveticaBold(),
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                    pw.SizedBox(height: 2),
                    PdfKannadaShaper.hasKannada(list.clientName)
                        ? pw.Row(
                            children: [
                              pw.Text(
                                'Client: ',
                                style: const pw.TextStyle(
                                  fontSize: 10.5,
                                  color: textDark,
                                ),
                              ),
                              PdfKannadaShaper.buildShapedText(
                                list.clientName,
                                fontSize: 10.5,
                                color: textDark,
                                isBold: false,
                                fonts: fonts,
                              ),
                              if (list.clientPhone != null &&
                                  list.clientPhone!.trim().isNotEmpty)
                                pw.Text(
                                  ' (${list.clientPhone})',
                                  style: const pw.TextStyle(
                                    fontSize: 10.5,
                                    color: textDark,
                                  ),
                                ),
                            ],
                          )
                        : pw.Text(
                            'Client: ${list.clientName}${list.clientPhone != null && list.clientPhone!.trim().isNotEmpty ? ' (${list.clientPhone})' : ''}',
                            style: const pw.TextStyle(
                              fontSize: 10.5,
                              color: textDark,
                            ),
                          ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    AppDateUtils.formatDisplayDate(list.eventDate),
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 11,
                      color: secondaryColor,
                    ),
                  ),
                  if (list.guestCount != null && list.guestCount! > 0)
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          '${list.guestCount} Guests / ',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 10,
                            color: accentColor,
                          ),
                        ),
                        PdfKannadaShaper.buildShapedText(
                          'ಜನರಿಗೆ',
                          fontSize: 10,
                          color: accentColor,
                          isBold: true,
                          fonts: fonts,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          if (list.location != null && list.location!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            PdfKannadaShaper.hasKannada(list.location)
                ? pw.Row(
                    children: [
                      pw.Text(
                        'Location: ',
                        style: const pw.TextStyle(
                          fontSize: 9.5,
                          color: textMuted,
                        ),
                      ),
                      PdfKannadaShaper.buildShapedText(
                        list.location!,
                        fontSize: 9.5,
                        color: textMuted,
                        isBold: false,
                        fonts: fonts,
                      ),
                    ],
                  )
                : pw.Text(
                    'Location: ${list.location}',
                    style: const pw.TextStyle(
                      fontSize: 9.5,
                      color: textMuted,
                    ),
                  ),
          ],
          if (list.notes != null && list.notes!.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            PdfKannadaShaper.hasKannada(list.notes)
                ? pw.Row(
                    children: [
                      pw.Text(
                        'Special Notes: ',
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 9.5,
                          color: textMuted,
                        ),
                      ),
                      PdfKannadaShaper.buildShapedText(
                        list.notes!,
                        fontSize: 9.5,
                        color: textMuted,
                        isBold: false,
                        fonts: fonts,
                      ),
                    ],
                  )
                : pw.Text(
                    'Special Notes: ${list.notes}',
                    style: const pw.TextStyle(
                      fontSize: 9.5,
                      color: textMuted,
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  /// Builds summary stats banner for ingredients and categories.
  static pw.Widget buildSummaryStats(CateringList list) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFE4F0EB),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Ingredients: ${list.itemCount}',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 10,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'Categories: ${list.categoryCount}',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 10,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds category groups and ingredient rows as specified in Sections 5, 8, and 9.
  static List<pw.Widget> buildIngredientSections(
    CateringList list,
    PdfFonts fonts,
  ) {
    final grouped = list.groupedByCategory;

    return grouped.entries.map((entry) {
      final cat = CategorySeed.getCategory(entry.key);
      final items = entry.value;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Category Header (Section 9: HarfBuzz-shaped Kannada category name)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFEAEFEA),
                border: pw.Border(
                  left: pw.BorderSide(color: secondaryColor, width: 4),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      PdfKannadaShaper.hasKannada(cat.nameKannada)
                          ? PdfKannadaShaper.buildShapedText(
                              cat.nameKannada,
                              fontSize: 10.5,
                              color: primaryColor,
                              isBold: true,
                              fonts: fonts,
                            )
                          : pw.Text(
                              cat.nameKannada,
                              style: pw.TextStyle(
                                font: pw.Font.helveticaBold(),
                                fontSize: 10.5,
                                color: primaryColor,
                              ),
                            ),
                      if (cat.nameEnglish.trim().isNotEmpty)
                        pw.Text(
                          ' / ${cat.nameEnglish.toUpperCase()}',
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 10.5,
                            color: primaryColor,
                          ),
                        ),
                    ],
                  ),
                  pw.Text(
                    '${items.length} items',
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Category Ingredient Rows (Section 8)
            ...items.asMap().entries.map((itemEntry) {
              final index = itemEntry.key + 1;
              final item = itemEntry.value;

              return buildIngredientRow(index, item, fonts);
            }),
          ],
        ),
      );
    }).toList();
  }

  /// Builds an individual ingredient row (Section 8).
  /// Kannada is the primary line shaped with HarfBuzz.
  /// English is the secondary line in clean Helvetica.
  /// Quantity and unit appear right-aligned.
  static pw.Widget buildIngredientRow(
    int index,
    ListIngredient item,
    PdfFonts fonts,
  ) {
    final hasKannada = item.nameKannada.trim().isNotEmpty;
    final hasEnglish = item.nameEnglish.trim().isNotEmpty;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 5,
      ),
      decoration: pw.BoxDecoration(
        color: index % 2 == 0 ? const PdfColor.fromInt(0xFFFAFAFA) : PdfColors.white,
        border: const pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(
            width: 22,
            child: pw.Text(
              index.toString(),
              style: const pw.TextStyle(
                fontSize: 9,
                color: textMuted,
              ),
            ),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (hasKannada)
                  PdfKannadaShaper.hasKannada(item.nameKannada)
                      ? PdfKannadaShaper.buildShapedText(
                          item.nameKannada,
                          fontSize: 10,
                          color: textDark,
                          isBold: true,
                          fonts: fonts,
                        )
                      : pw.Text(
                          item.nameKannada,
                          style: pw.TextStyle(
                            font: pw.Font.helveticaBold(),
                            fontSize: 10,
                            color: textDark,
                          ),
                        ),
                if (hasEnglish) ...[
                  if (hasKannada) pw.SizedBox(height: 1.5),
                  pw.Text(
                    item.nameEnglish,
                    style: pw.TextStyle(
                      font: hasKannada
                          ? pw.Font.helvetica()
                          : pw.Font.helveticaBold(),
                      fontSize: hasKannada ? 8.5 : 10,
                      color: hasKannada ? PdfColors.grey700 : textDark,
                    ),
                  ),
                ],
                if (!hasKannada && !hasEnglish)
                  pw.Text(
                    'Unnamed Item',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: textMuted,
                    ),
                  ),
                if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 1.5),
                  pw.Row(
                    children: [
                      pw.Text(
                        'Note: ',
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 7.5,
                          color: accentColor,
                        ),
                      ),
                      PdfKannadaShaper.hasKannada(item.notes!)
                          ? PdfKannadaShaper.buildShapedText(
                              item.notes!,
                              fontSize: 8,
                              color: accentColor,
                              isBold: false,
                              fonts: fonts,
                            )
                          : pw.Text(
                              item.notes!,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: accentColor,
                              ),
                            ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              item.formattedWithUnit,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: pw.Font.helveticaBold(),
                fontSize: 9.5,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
