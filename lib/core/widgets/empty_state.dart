import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.space24),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryGreen.withAlpha(50), width: 2),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.secondaryGreen,
              ),
            ),
            const SizedBox(height: AppSizes.space20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.space8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSizes.space24),
              SizedBox(
                width: 220,
                child: PrimaryButton(
                  label: buttonText!,
                  onPressed: onButtonPressed,
                ),
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: AppSizes.space24),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}
