import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/category_seed.dart';
import '../../../models/catering_list.dart';
import '../../../models/list_ingredient.dart';
import '../../../services/share_service.dart';

class ClientPreviewScreen extends ConsumerWidget {
  final String listId;

  const ClientPreviewScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);
    final draft = ref.watch(currentDraftListProvider);
    final savedLists = ref.watch(savedListsProvider);

    // If draft matches this ID, use it; else find in savedLists
    CateringList? targetList =
        (draft != null && draft.id == listId) ? draft : null;
    if (targetList == null) {
      try {
        targetList = savedLists.firstWhere((l) => l.id == listId);
      } catch (_) {
        targetList = draft;
      }
    }

    if (targetList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: const Center(child: Text('List not found')),
      );
    }

    final validationErrors = targetList.getValidationErrors();
    final bool isValid = validationErrors.isEmpty;
    final grouped = targetList.groupedByCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Client Document Preview'),
        actions: [
          IconButton(
            tooltip: 'Print or Preview PDF Document',
            icon: const Icon(Icons.picture_as_pdf_rounded,
                color: AppColors.primaryGreen),
            onPressed: () => ShareService.printOrPreviewPdf(
              list: targetList!,
              profile: profile,
            ),
          ),
          IconButton(
            tooltip: 'Copy as Text',
            icon: const Icon(Icons.copy_rounded, color: AppColors.secondaryGreen),
            onPressed: () async {
              await ShareService.copyToClipboard(
                list: targetList!,
                profile: profile,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied bilingual list to clipboard!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Validation Warning banner if incomplete
            if (!isValid)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.warningLight,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Missing information: ${validationErrors.join(', ')}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Paper Document Visual Preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.pageHorizontalPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Document Header: Caterer Business
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.businessName.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (profile.tagline != null &&
                                    profile.tagline!.isNotEmpty)
                                  Text(
                                    profile.tagline!,
                                    style: GoogleFonts.anekKannada(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  '📞 ${profile.phone}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'REQUIREMENT LIST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'ಸಾಮಾನುಗಳ ಪಟ್ಟಿ',
                                  style: GoogleFonts.anekKannada(
                                    fontSize: 11,
                                    color: AppColors.softOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.primaryGreen, thickness: 2),
                      const SizedBox(height: 12),

                      // Event & Client Metadata Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    targetList.eventName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                if (targetList.guestCount != null &&
                                    targetList.guestCount! > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.softOrange,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${targetList.guestCount} Guests / ಜನರಿಗೆ',
                                      style: GoogleFonts.anekKannada(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.orangeDark,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Client: ${targetList.clientName} ${targetList.clientPhone != null ? "(${targetList.clientPhone})" : ""}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date: ${AppDateUtils.formatDateTimeCombined(targetList.eventDate, targetList.eventTime)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (targetList.location != null &&
                                targetList.location!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Location: ${targetList.location}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (targetList.notes != null &&
                                targetList.notes!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Notes: ${targetList.notes}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Ingredients grouped by category
                      ...grouped.entries.map((entry) {
                        final cat = CategorySeed.getCategory(entry.key);
                        final items = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.softGreen,
                                  borderRadius: BorderRadius.circular(6),
                                  border: const Border(
                                    left: BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 3.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${cat.nameKannada} / ${cat.nameEnglish.toUpperCase()}',
                                      style: GoogleFonts.anekKannada(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    Text(
                                      '${items.length} items',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Items List in category
                              ...items.asMap().entries.map((itemEntry) {
                                final idx = itemEntry.key + 1;
                                final item = itemEntry.value;

                                return _buildPreviewItemRow(idx, item);
                              }),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 8),

                      // Document Summary Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items: ${targetList.itemCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Generated via CaterPrep',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Share Actions Bottom Bar
            Container(
              padding: const EdgeInsets.all(AppSizes.pageHorizontalPadding),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // WhatsApp Primary Action Button
                  PrimaryButton(
                    label: 'Share via WhatsApp • ವಾಟ್ಸಾಪ್ ಕಳುಹಿಸಿ',
                    icon: Icons.chat_bubble_rounded,
                    backgroundColor: const Color(0xFF25D366),
                    textColor: Colors.white,
                    onPressed: () async {
                      await ShareService.shareToWhatsApp(
                        list: targetList!,
                        profile: profile,
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Secondary Action Buttons Row: Save & Export PDF
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Export PDF',
                          icon: Icons.download_rounded,
                          isOutlined: true,
                          onPressed: () => ShareService.shareAsPdf(
                            list: targetList!,
                            profile: profile,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Save List',
                          icon: Icons.save_rounded,
                          backgroundColor: AppColors.primaryGreen,
                          onPressed: () async {
                            await ref
                                .read(currentDraftListProvider.notifier)
                                .commitAndSave();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('List saved successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              context.go('/lists');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItemRow(int index, ListIngredient item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textPrimary),
                    children: [
                      TextSpan(
                        text: item.nameKannada,
                        style: GoogleFonts.anekKannada(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                        text: ' / ',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      TextSpan(
                        text: item.nameEnglish,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Text(
                    'Note: ${item.notes}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.orangeDark,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.formattedWithUnit,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
