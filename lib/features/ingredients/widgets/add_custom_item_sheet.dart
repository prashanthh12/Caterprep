import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_units.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/category.dart';
import '../../../models/ingredient.dart';

class AddCustomItemSheet extends ConsumerStatefulWidget {
  const AddCustomItemSheet({super.key});

  static Future<Ingredient?> show(BuildContext context) {
    return showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCustomItemSheet(),
    );
  }

  @override
  ConsumerState<AddCustomItemSheet> createState() => _AddCustomItemSheetState();
}

class _AddCustomItemSheetState extends ConsumerState<AddCustomItemSheet> {
  final _formKey = GlobalKey<FormState>();

  final _kannadaNameCtrl = TextEditingController();
  final _englishNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _notesCtrl = TextEditingController();

  String _selectedCategory = 'other';
  String _selectedUnit = 'kg';

  @override
  void dispose() {
    _kannadaNameCtrl.dispose();
    _englishNameCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final kn = _kannadaNameCtrl.text.trim();
    final en = _englishNameCtrl.text.trim();

    if (kn.isEmpty && en.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least Kannada or English name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    const uuid = Uuid();
    final customIngredient = Ingredient(
      id: 'CUSTOM_${uuid.v4().substring(0, 8)}',
      nameKannada: kn.isNotEmpty ? kn : en,
      nameEnglish: en.isNotEmpty ? en : kn,
      categoryId: _selectedCategory,
      defaultUnit: _selectedUnit,
      searchKeywords: [
        kn.toLowerCase(),
        en.toLowerCase(),
        'custom',
      ],
      isCustom: true,
    );

    // Save to custom repository catalog
    ref.read(ingredientCatalogProvider.notifier).addCustomIngredient(customIngredient);

    // Add directly to active draft list
    ref.read(currentDraftListProvider.notifier).toggleIngredient(customIngredient);

    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    ref.read(currentDraftListProvider.notifier).updateItemQuantity(
          customIngredient.id,
          qty,
        );
    ref.read(currentDraftListProvider.notifier).updateItemUnit(
          customIngredient.id,
          _selectedUnit,
        );

    Navigator.of(context).pop(customIngredient);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.sheetRadius),
          topRight: Radius.circular(AppSizes.sheetRadius),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSizes.space20,
        left: AppSizes.pageHorizontalPadding,
        right: AppSizes.pageHorizontalPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.space20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space16),

              const Text(
                'Add Custom Ingredient',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Text(
                'ಹೊಸ ಪದಾರ್ಥವನ್ನು ಸೇರಿಸಿ • Reusable in lists',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.space16),

              // Kannada Name
              AppTextField(
                label: 'Kannada Name (ಕನ್ನಡ ಹೆಸರು)',
                hint: 'ಉದಾ: ಮಜ್ಜಿಗೆ ಹುಲ್ಲು, ಬಾಳೆ ಹೂವು',
                controller: _kannadaNameCtrl,
                prefixIcon: const Icon(Icons.edit_rounded),
              ),
              const SizedBox(height: AppSizes.space12),

              // English Name
              AppTextField(
                label: 'English Name (ಇಂಗ್ಲಿಷ್ ಹೆಸರು)',
                hint: 'e.g. Lemongrass, Banana Flower',
                controller: _englishNameCtrl,
                prefixIcon: const Icon(Icons.language_rounded),
              ),
              const SizedBox(height: AppSizes.space12),

              // Category Selector Dropdown
              const Text(
                'Category (ವರ್ಗ)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: categories.map((Category cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Text('${cat.nameKannada} / ${cat.nameEnglish}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSizes.space12),

              // Quantity & Unit Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Default Quantity',
                      hint: '1',
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.scale_rounded),
                    ),
                  ),
                  const SizedBox(width: AppSizes.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unit (ಪ್ರಮಾಣ)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: AppUnits.allUnits.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.code,
                              child: Text('${u.display} (${u.displayKannada})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.space20),

              PrimaryButton(
                label: 'Add & Select • ಪಟ್ಟಿಗೆ ಸೇರಿಸಿ',
                icon: Icons.check_circle_rounded,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
