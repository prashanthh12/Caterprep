import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/catering_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);
    final savedLists = ref.watch(savedListsProvider);
    final templates = ref.watch(templatesProvider);
    final draft = ref.watch(currentDraftListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.businessName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            Text(
              'Caterer: ${profile.name}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Business Profile',
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.softGreen,
              child: Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
            ),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Riverpod automatically keeps data reactive
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontalPadding,
            vertical: AppSizes.space16,
          ),
          children: [
            // In-Progress Draft Alert Card (if any draft exists)
            if (draft != null && draft.items.isNotEmpty) ...[
              _buildDraftResumeCard(context, ref, draft),
              const SizedBox(height: AppSizes.space16),
            ],

            // Primary Call-to-Action: Create New List
            _buildCreateListHeroCard(context, ref),
            const SizedBox(height: AppSizes.space24),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    title: 'Saved Lists',
                    value: '${savedLists.length}',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.primaryGreen,
                    onTap: () => context.go('/lists'),
                  ),
                ),
                const SizedBox(width: AppSizes.space12),
                Expanded(
                  child: _buildStatTile(
                    title: 'Templates',
                    value: '${templates.length}',
                    icon: Icons.bookmark_added_rounded,
                    color: AppColors.secondaryGreen,
                    onTap: () => context.go('/templates'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space24),

            // Section: Upcoming Events / Recent Lists
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Event Lists',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (savedLists.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go('/lists'),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),

            if (savedLists.isEmpty)
              _buildEmptyListsPlaceholder(context, ref)
            else
              ...savedLists.take(3).map((list) => _buildRecentListCard(context, ref, list)),

            const SizedBox(height: AppSizes.space24),

            // Section: Quick Templates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Templates',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/templates'),
                  child: const Text('All Templates'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space8),

            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSizes.space12),
                itemBuilder: (context, index) {
                  final t = templates[index];
                  return _buildTemplateCard(context, ref, t);
                },
              ),
            ),
            const SizedBox(height: AppSizes.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftResumeCard(
      BuildContext context, WidgetRef ref, CateringList draft) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.softOrange,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.orangeAccent.withAlpha(100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.orangeAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSizes.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unfinished List in Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orangeDark,
                  ),
                ),
                Text(
                  '${draft.eventName.isNotEmpty ? draft.eventName : "Untitled"} (${draft.items.length} items)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(60, 36),
            ),
            onPressed: () => context.push('/lists/${draft.id}/items'),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateListHeroCard(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          onTap: () {
            ref.read(currentDraftListProvider.notifier).startNewList();
            final draft = ref.read(currentDraftListProvider);
            if (draft != null) {
              context.push('/lists/${draft.id}/edit');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'FAST CREATOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.space12),
                      const Text(
                        'Create New Catering List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ಹೊಸ ಸಾಮಾನುಗಳ ಪಟ್ಟಿ ರಚಿಸಿ • Bilingual & Fast',
                        style: GoogleFonts.anekKannada(
                          fontSize: 13,
                          color: AppColors.softGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSizes.space12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentListCard(
      BuildContext context, WidgetRef ref, CateringList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.space12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: () => context.push('/lists/${list.id}/preview'),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.space16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${list.itemCount}\nitems',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.eventName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Client: ${list.clientName}${list.guestCount != null ? " • ${list.guestCount} Guests" : ""}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppDateUtils.formatDisplayDate(list.eventDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
      BuildContext context, WidgetRef ref, dynamic template) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          onTap: () {
            ref.read(currentDraftListProvider.notifier).startNewList(fromTemplate: template);
            final draft = ref.read(currentDraftListProvider);
            if (draft != null) {
              context.push('/lists/${draft.id}/edit');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${template.guestCount} Guests',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                        ),
                        Text(
                          '${template.items.length} items',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.orangeAccent),
                    SizedBox(width: 4),
                    Text(
                      'Use Template',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyListsPlaceholder(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.secondaryGreen,
          ),
          const SizedBox(height: 8),
          const Text(
            'No catering lists created yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create your first client list or pick a template above.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ref.read(currentDraftListProvider.notifier).startNewList();
              final draft = ref.read(currentDraftListProvider);
              if (draft != null) {
                context.push('/lists/${draft.id}/edit');
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 36),
            ),
            child: const Text('Create First List'),
          ),
        ],
      ),
    );
  }
}
