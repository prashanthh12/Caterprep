import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_units.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/list_ingredient.dart';

class EditIngredientSheet extends ConsumerStatefulWidget {
  final ListIngredient item;

  const EditIngredientSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, ListIngredient item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIngredientSheet(item: item),
    );
  }

  @override
  ConsumerState<EditIngredientSheet> createState() =>
      _EditIngredientSheetState();
}

class _EditIngredientSheetState extends ConsumerState<EditIngredientSheet> {
  late TextEditingController _quantityCtrl;
  late TextEditingController _notesCtrl;
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _quantityCtrl = TextEditingController(
      text: QuantityUtils.formatQuantity(widget.item.quantity),
    );
    _notesCtrl = TextEditingController(text: widget.item.notes ?? '');
    _selectedUnit = widget.item.unit;
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _increment() {
    final cur = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    final next = QuantityUtils.increment(cur, _selectedUnit);
    _quantityCtrl.text = QuantityUtils.formatQuantity(next);
  }

  void _decrement() {
    final cur = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    final next = QuantityUtils.decrement(cur, _selectedUnit);
    _quantityCtrl.text = QuantityUtils.formatQuantity(next);
  }

  void _save() {
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 1.0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be greater than 0'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final updated = widget.item.copyWith(
      quantity: qty,
      unit: _selectedUnit,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    ref.read(currentDraftListProvider.notifier).updateItemDetails(updated);
    Navigator.of(context).pop();
  }

  void _remove() {
    ref.read(currentDraftListProvider.notifier).removeItem(widget.item.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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

            // Item Identity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.nameKannada,
                        style: GoogleFonts.anekKannada(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      Text(
                        widget.item.nameEnglish,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove from List',
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: _remove,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space20),

            // Quantity Stepper & Manual Input
            const Text(
              'Quantity (ಪ್ರಮಾಣ)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLargeStepperBtn(
                  icon: Icons.remove,
                  onTap: _decrement,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: true,
                      fillColor: AppColors.lightGreen,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.secondaryGreen),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildLargeStepperBtn(
                  icon: Icons.add,
                  onTap: _increment,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.space16),

            // Unit Selector
            const Text(
              'Unit (ಘಟಕ)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppUnits.allUnits.map((u) {
                final isSelected = _selectedUnit.toLowerCase() == u.code.toLowerCase();
                return ChoiceChip(
                  label: Text('${u.display} (${u.displayKannada})'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedUnit = u.code);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSizes.space16),

            // Optional Note
            AppTextField(
              label: 'Kitchen Note (ವಿಶೇಷ ಸೂಚನೆ - ಐಚ್ಛಿಕ)',
              hint: 'e.g. Sona Masoori brand, fine quality, peeled',
              controller: _notesCtrl,
              prefixIcon: const Icon(Icons.sticky_note_2_outlined),
            ),
            const SizedBox(height: AppSizes.space24),

            // Save CTA
            PrimaryButton(
              label: 'Save Changes • ಬದಲಾವಣೆ ಉಳಿಸಿ',
              icon: Icons.check_circle_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.softGreen,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondaryGreen.withAlpha(80)),
        ),
        child: Icon(icon, size: 24, color: AppColors.primaryGreen),
      ),
    );
  }
}
