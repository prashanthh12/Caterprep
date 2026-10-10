import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/catering_list.dart';

class SavedListsScreen extends ConsumerWidget {
  const SavedListsScreen({super.key});

  void _showSaveAsTemplateDialog(
      BuildContext context, WidgetRef ref, CateringList list) {
    final nameCtrl = TextEditingController(text: '${list.eventName} Template');
    final descCtrl = TextEditingController(
        text: 'Template with ${list.itemCount} items from ${list.clientName}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Reusable Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Template Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await ref
                    .read(templatesProvider.notifier)
                    .createTemplateFromList(
                      list,
                      templateName: nameCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved as new template!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Template'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(savedListsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Catering Lists'),
        actions: [
          IconButton(
            tooltip: 'Create New List',
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryGreen),
            onPressed: () {
              ref.read(currentDraftListProvider.notifier).startNewList();
              final draft = ref.read(currentDraftListProvider);
              if (draft != null) {
                context.push('/lists/${draft.id}/edit');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: lists.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'No saved lists yet',
              description: 'Create your first client ingredient list or pick a template.',
              buttonText: 'Create New List',
              onButtonPressed: () {
                ref.read(currentDraftListProvider.notifier).startNewList();
                final draft = ref.read(currentDraftListProvider);
                if (draft != null) {
                  context.push('/lists/${draft.id}/edit');
                }
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pageHorizontalPadding,
                vertical: AppSizes.space16,
              ),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.space12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    onTap: () => context.push('/lists/${list.id}/preview'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  list.eventName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.softGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${list.itemCount} items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 15, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                list.clientName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (list.guestCount != null) ...[
                                const SizedBox(width: 10),
                                const Icon(Icons.groups_outlined,
                                    size: 15, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${list.guestCount} guests',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 14, color: AppColors.secondaryGreen),
                              const SizedBox(width: 4),
                              Text(
                                AppDateUtils.formatDisplayDate(list.eventDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (list.location != null &&
                                  list.location!.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                const Icon(Icons.place_outlined,
                                    size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    list.location!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          // Action Buttons Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Edit
                              TextButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: AppColors.secondaryGreen,
                                ),
                                onPressed: () {
                                  ref
                                      .read(currentDraftListProvider.notifier)
                                      .loadExistingList(list);
                                  context.push('/lists/${list.id}/items');
                                },
                              ),
                              // Duplicate
                              TextButton.icon(
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: const Text('Duplicate'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: AppColors.orangeDark,
                                ),
                                onPressed: () async {
                                  final dup = await ref
                                      .read(savedListsProvider.notifier)
                                      .duplicateList(list);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Duplicated list as "${dup.title}"'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                              // More Menu (Save as template, delete)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (val) async {
                                  if (val == 'template') {
                                    _showSaveAsTemplateDialog(context, ref, list);
                                  } else if (val == 'delete') {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete List?'),
                                        content: Text(
                                            'Are you sure you want to delete "${list.eventName}"?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                                foregroundColor: AppColors.error),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await ref
                                          .read(savedListsProvider.notifier)
                                          .deleteList(list.id);
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'template',
                                    child: Row(
                                      children: [
                                        Icon(Icons.bookmark_add_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('Save as Template'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            size: 18, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Delete List',
                                            style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
