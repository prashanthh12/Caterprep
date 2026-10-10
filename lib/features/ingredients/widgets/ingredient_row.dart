import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_units.dart';
import '../../../core/utils/quantity_utils.dart';
import '../../../models/ingredient.dart';
import '../../../models/list_ingredient.dart';

class IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final ListIngredient? selectedItem;
  final VoidCallback onToggle;
  final ValueChanged<double>? onQuantityChanged;
  final ValueChanged<String>? onUnitChanged;
  final VoidCallback? onEditDetails;

  const IngredientRow({
    super.key,
    required this.ingredient,
    required this.selectedItem,
    required this.onToggle,
    this.onQuantityChanged,
    this.onUnitChanged,
    this.onEditDetails,
  });

  bool get isSelected => selectedItem != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: AppSizes.space8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.lightGreen : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.secondaryGreen : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                // Selection Checkbox Target
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Bilingual Item Name Labels
                Expanded(
                  child: InkWell(
                    onTap: onToggle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.nameKannada,
                          style: GoogleFonts.anekKannada(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          ingredient.nameEnglish,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (selectedItem?.notes != null &&
                            selectedItem!.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Note: ${selectedItem!.notes}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.orangeDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // If not selected: Add Quick Chip
                if (!isSelected)
                  InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add,
                              size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 2),
                          Text(
                            ingredient.defaultUnit,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // If selected: Edit / Notes icon
                if (isSelected && onEditDetails != null)
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    color: AppColors.secondaryGreen,
                    tooltip: 'Edit quantity, unit or notes',
                    onPressed: onEditDetails,
                  ),
              ],
            ),

            // If selected: Fast Quantity Stepper & Unit Dropdown Bar
            if (isSelected && selectedItem != null) ...[
              const SizedBox(height: 8),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stepper (- / +)
                  Row(
                    children: [
                      _buildStepperBtn(
                        icon: Icons.remove,
                        onTap: () {
                          if (onQuantityChanged != null) {
                            final next = QuantityUtils.decrement(
                              selectedItem!.quantity,
                              selectedItem!.unit,
                            );
                            onQuantityChanged!(next);
                          }
                        },
                      ),
                      InkWell(
                        onTap: onEditDetails,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 54),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            QuantityUtils.formatQuantity(selectedItem!.quantity),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      _buildStepperBtn(
                        icon: Icons.add,
                        onTap: () {
                          if (onQuantityChanged != null) {
                            final next = QuantityUtils.increment(
                              selectedItem!.quantity,
                              selectedItem!.unit,
                            );
                            onQuantityChanged!(next);
                          }
                        },
                      ),
                    ],
                  ),

                  // Unit Selector Dropdown
                  PopupMenuButton<String>(
                    initialValue: selectedItem!.unit,
                    tooltip: 'Select Unit',
                    onSelected: (u) {
                      if (onUnitChanged != null) {
                        onUnitChanged!(u);
                      }
                    },
                    itemBuilder: (context) {
                      return AppUnits.allUnits.map((u) {
                        return PopupMenuItem<String>(
                          value: u.code,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${u.display} (${u.displayKannada})',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                u.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.secondaryGreen),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${selectedItem!.unit} (${AppUnits.getUnit(selectedItem!.unit).displayKannada})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down,
                              size: 18, color: AppColors.secondaryGreen),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepperBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryGreen),
      ),
    );
  }
}

