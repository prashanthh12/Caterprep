import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontalPadding,
            vertical: AppSizes.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              // App Icon / Logo Graphic
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      size: 52,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space24),

              // Title & Branding
              Text(
                'CaterPrep',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSizes.space8),
              Text(
                'ಕ್ಯಾಟರಿಂಗ್ ಪದಾರ್ಥಗಳ ಡಿಜಿಟಲ್ ಪಟ್ಟಿ',
                textAlign: TextAlign.center,
                style: GoogleFonts.anekKannada(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.orangeAccent,
                ),
              ),
              const SizedBox(height: AppSizes.space16),

              // Value Proposition Banner
              Container(
                padding: const EdgeInsets.all(AppSizes.space20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                    color: Colors.white.withAlpha(35),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeatureBullet(
                      icon: Icons.checklist_rtl_rounded,
                      title: '100% Paperless Workflow',
                      subtitle: 'Replace handwritten slips with instant digital lists',
                    ),
                    const SizedBox(height: AppSizes.space16),
                    _buildFeatureBullet(
                      icon: Icons.translate_rounded,
                      title: 'Bilingual Kannada & English',
                      subtitle: 'ಅಕ್ಕಿ / Rice, ಈರುಳ್ಳಿ / Onion — built for Karnataka kitchens',
                    ),
                    const SizedBox(height: AppSizes.space16),
                    _buildFeatureBullet(
                      icon: Icons.share_rounded,
                      title: 'Instant WhatsApp & PDF Export',
                      subtitle: 'Professional, client-ready requirement sheets in 1-tap',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // CTA Button
              PrimaryButton(
                label: 'Get Started • ಪ್ರಾರಂಭಿಸಿ',
                backgroundColor: AppColors.orangeAccent,
                textColor: Colors.white,
                onPressed: () => context.go('/dashboard'),
              ),
              const SizedBox(height: AppSizes.space16),
              Center(
                child: Text(
                  'Single Caterer • Offline First • Fast & Clean',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softGreen.withAlpha(40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.softOrange, size: 20),
        ),
        const SizedBox(width: AppSizes.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withAlpha(200),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
