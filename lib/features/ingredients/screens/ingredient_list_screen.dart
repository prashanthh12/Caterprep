import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/category.dart';
import '../../../models/ingredient.dart';
import '../../../models/list_ingredient.dart';
import '../widgets/add_custom_item_sheet.dart';
import '../widgets/category_chip.dart';
import '../widgets/ingredient_row.dart';
import 'edit_ingredient_screen.dart';

class IngredientListScreen extends ConsumerStatefulWidget {
  final String listId;

  const IngredientListScreen({super.key, required this.listId});

  @override
  ConsumerState<IngredientListScreen> createState() =>
      _IngredientListScreenState();
}

class _IngredientListScreenState extends ConsumerState<IngredientListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showSelectedOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(currentDraftListProvider);
    final allIngredients = ref.watch(ingredientCatalogProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final searchQuery = ref.watch(ingredientSearchFilterProvider);

    // Map selected ingredients by ID
    final Map<String, ListIngredient> selectedMap = {};
    if (draft != null) {
      for (final item in draft.items) {
        selectedMap[item.ingredientId] = item;
      }
    }

    // Filter ingredients
    List<Ingredient> filteredIngredients = allIngredients.where((ing) {
      if (_showSelectedOnly && !selectedMap.containsKey(ing.id)) {
        return false;
      }
      if (selectedCategory != null &&
          ing.categoryId.toLowerCase() != selectedCategory.toLowerCase()) {
        return false;
      }
      if (searchQuery.isNotEmpty && !ing.matchesQuery(searchQuery)) {
        return false;
      }
      return true;
    }).toList();

    final selectedCount = draft?.items.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft?.eventName.isNotEmpty == true
                  ? draft!.eventName
                  : 'Select Ingredients',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Client: ${draft?.clientName ?? "Draft"}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => AddCustomItemSheet.show(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Custom'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.orangeDark,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Quick Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.pageHorizontalPadding,
              8,
              AppSizes.pageHorizontalPadding,
              12,
            ),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Input Box
                TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    ref.read(ingredientSearchFilterProvider.notifier).setQuery(val.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search ಅಕ್ಕಿ, Rice, Onion, ಈರುಳ್ಳಿ...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.secondaryGreen),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref
                                  .read(ingredientSearchFilterProvider.notifier)
                                  .setQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // View Toggle: All vs Selected
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('All Items (${allIngredients.length})'),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Selected ($selectedCount)'),
                          ),
                        ],
                        selected: {_showSelectedOnly},
                        onSelectionChanged: (val) {
                          setState(() {
                            _showSelectedOnly = val.first;
                          });
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Horizontal Category Chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryFilterChip(
                        category: null,
                        isSelected: selectedCategory == null,
                        onTap: () {
                          ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .setCategory(null);
                        },
                      ),
                      ...categories.map((Category cat) {
                        final isSel = selectedCategory == cat.id;
                        // Count items in category
                        final count = draft?.items
                            .where((i) => i.categoryId == cat.id)
                            .length;
                        return CategoryFilterChip(
                          category: cat,
                          isSelected: isSel,
                          count: count,
                          onTap: () {
                            ref
                                .read(selectedCategoryFilterProvider.notifier)
                                .setCategory(isSel ? null : cat.id);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Items List View
          Expanded(
            child: filteredIngredients.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No ingredients found',
                    description: searchQuery.isNotEmpty
                        ? 'No match for "$searchQuery". Try Kannada or English keywords, or add as custom item.'
                        : 'No items in this category yet.',
                    buttonText: 'Add Custom Item',
                    onButtonPressed: () => AddCustomItemSheet.show(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pageHorizontalPadding,
                      vertical: AppSizes.space12,
                    ),
                    itemCount: filteredIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = filteredIngredients[index];
                      final selected = selectedMap[ingredient.id];

                      return IngredientRow(
                        key: ValueKey(ingredient.id),
                        ingredient: ingredient,
                        selectedItem: selected,
                        onToggle: () {
                          ref
                              .read(currentDraftListProvider.notifier)
                              .toggleIngredient(ingredient);
                        },
                        onQuantityChanged: (qty) {
                          ref
                              .read(currentDraftListProvider.notifier)
                              .updateItemQuantity(ingredient.id, qty);
                        },
                        onUnitChanged: (unit) {
                          ref
                              .read(currentDraftListProvider.notifier)
                              .updateItemUnit(ingredient.id, unit);
                        },
                        onEditDetails: selected != null
                            ? () => EditIngredientSheet.show(context, selected)
                            : null,
                      );
                    },
                  ),
          ),

          // Bottom Continue to Client Preview Bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pageHorizontalPadding,
              vertical: AppSizes.space16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedCount items chosen',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    Text(
                      '${draft?.categoryCount ?? 0} categories',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSizes.space16),
                Expanded(
                  child: PrimaryButton(
                    label: 'Client Preview • ಮುನ್ನೋಟ',
                    icon: Icons.visibility_rounded,
                    onPressed: selectedCount == 0
                        ? null
                        : () => context.push('/lists/${widget.listId}/preview'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
