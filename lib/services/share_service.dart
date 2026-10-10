import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/date_utils.dart';
import '../data/category_seed.dart';
import '../models/catering_list.dart';
import '../models/user.dart';
import 'pdf_service.dart';

class ShareService {
  static String formatListForTextShare({
    required CateringList list,
    required BusinessProfile profile,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📋 *${profile.businessName.toUpperCase()}*');
    if (profile.tagline != null && profile.tagline!.isNotEmpty) {
      buffer.writeln('${profile.tagline}');
    }
    buffer.writeln('📞 Contact: ${profile.phone}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🍽️ *Event:* ${list.eventName}');
    buffer.writeln('👤 *Client:* ${list.clientName}');
    buffer.writeln('📅 *Date:* ${AppDateUtils.formatDisplayDate(list.eventDate)}');
    if (list.guestCount != null && list.guestCount! > 0) {
      buffer.writeln('👥 *Guests:* ${list.guestCount} People');
    }
    if (list.location != null && list.location!.isNotEmpty) {
      buffer.writeln('📍 *Location:* ${list.location}');
    }
    if (list.notes != null && list.notes!.isNotEmpty) {
      buffer.writeln('📝 *Notes:* ${list.notes}');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🛒 *INGREDIENT REQUIREMENT LIST / ಸಾಮಾನುಗಳ ಪಟ್ಟಿ:*\n');

    final grouped = list.groupedByCategory;
    for (final entry in grouped.entries) {
      final category = CategorySeed.getCategory(entry.key);
      buffer.writeln('📌 *${category.nameKannada} / ${category.nameEnglish.toUpperCase()}*');
      for (final item in entry.value) {
        final noteStr = item.notes != null && item.notes!.isNotEmpty ? ' (${item.notes})' : '';
        buffer.writeln(' • ${item.nameKannada} / ${item.nameEnglish}: *${item.formattedWithUnit}*$noteStr');
      }
      buffer.writeln('');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✅ Total Ingredients: ${list.itemCount} across ${list.categoryCount} categories');
    buffer.writeln('Prepared digitally via *CaterPrep*');
    return buffer.toString();
  }

  static Future<bool> shareToWhatsApp({
    required CateringList list,
    required BusinessProfile profile,
  }) async {
    final message = formatListForTextShare(list: list, profile: profile);
    final encodedMessage = Uri.encodeComponent(message);

    // If client has phone number, direct to client
    String url;
    if (list.clientPhone != null && list.clientPhone!.trim().isNotEmpty) {
      var phone = list.clientPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.length == 10) {
        phone = '91$phone'; // Default India country code
      }
      url = 'https://wa.me/$phone?text=$encodedMessage';
    } else {
      url = 'https://wa.me/?text=$encodedMessage';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: share via system share sheet or clipboard
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: '${list.eventName} - Ingredient List',
        ),
      );
      return true;
    }
  }

  static Future<void> shareAsPdf({
    required CateringList list,
    required BusinessProfile profile,
  }) async {
    final pdfBytes = await PdfService.generateCateringListPdf(
      list: list,
      profile: profile,
    );
    final fileName = '${list.clientName}_${list.eventName}_Ingredients.pdf'
        .replaceAll(RegExp(r'\s+'), '_');

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }

  static Future<void> printOrPreviewPdf({
    required CateringList list,
    required BusinessProfile profile,
  }) async {
    final pdfBytes = await PdfService.generateCateringListPdf(
      list: list,
      profile: profile,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: '${list.clientName}_${list.eventName}_CaterPrep',
    );
  }

  static Future<void> copyToClipboard({
    required CateringList list,
    required BusinessProfile profile,
  }) async {
    final message = formatListForTextShare(list: list, profile: profile);
    await Clipboard.setData(ClipboardData(text: message));
  }
}
