import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _businessNameCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _taglineCtrl;
  String _preferredLanguage = 'bilingual';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _businessNameCtrl = TextEditingController(text: profile.businessName);
    _nameCtrl = TextEditingController(text: profile.name);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _emailCtrl = TextEditingController(text: profile.email ?? '');
    _addressCtrl = TextEditingController(text: profile.address ?? '');
    _taglineCtrl = TextEditingController(text: profile.tagline ?? '');
    _preferredLanguage = profile.preferredLanguage;
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final current = ref.read(businessProfileProvider);
      final updated = current.copyWith(
        businessName: _businessNameCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        tagline: _taglineCtrl.text.trim().isEmpty ? null : _taglineCtrl.text.trim(),
        preferredLanguage: _preferredLanguage,
      );

      await ref.read(businessProfileProvider.notifier).updateProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Caterer Business Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pageHorizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branding Header Card
                Container(
                  padding: const EdgeInsets.all(AppSizes.space16),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(
                        color: AppColors.secondaryGreen.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Document Header Details',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'These details appear at the top of every generated PDF and WhatsApp message.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.space20),

                // Catering Business Name
                AppTextField(
                  label: 'Catering Business / Service Name',
                  hint: 'e.g. Sri Raghavendra Catering Services',
                  controller: _businessNameCtrl,
                  isRequired: true,
                  prefixIcon: const Icon(Icons.storefront_rounded),
                ),
                const SizedBox(height: AppSizes.space16),

                // Caterer / Chef Name
                AppTextField(
                  label: 'Caterer / Chef Name',
                  hint: 'e.g. Prashanth Bhat',
                  controller: _nameCtrl,
                  isRequired: true,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                const SizedBox(height: AppSizes.space16),

                // Phone
                AppTextField(
                  label: 'Phone Number (Printed on PDF)',
                  hint: 'e.g. +91 98450 12345',
                  controller: _phoneCtrl,
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                const SizedBox(height: AppSizes.space16),

                // Email
                AppTextField(
                  label: 'Email Address (Optional)',
                  hint: 'e.g. contact@catering.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppSizes.space16),

                // Tagline / Motto
                AppTextField(
                  label: 'Business Tagline / Kannada Subtitle',
                  hint: 'e.g. ಶುದ್ಧ ಸಾಂಪ್ರದಾಯಿಕ ಅಡುಗೆ ಸೇವೆ • Authentic Traditional Catering',
                  controller: _taglineCtrl,
                  prefixIcon: const Icon(Icons.format_quote_rounded),
                ),
                const SizedBox(height: AppSizes.space16),

                // Address
                AppTextField(
                  label: 'Business Address / City',
                  hint: 'e.g. Malleswaram, Bengaluru, Karnataka',
                  controller: _addressCtrl,
                  prefixIcon: const Icon(Icons.location_city_rounded),
                ),
                const SizedBox(height: AppSizes.space20),

                // Display Mode Preference
                const Text(
                  'Default Display Preference',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Bilingual (Kannada + English)'),
                      selected: _preferredLanguage == 'bilingual',
                      onSelected: (sel) {
                        if (sel) setState(() => _preferredLanguage = 'bilingual');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Kannada First (ಕನ್ನಡ ಮೊದಲು)'),
                      selected: _preferredLanguage == 'kannada',
                      onSelected: (sel) {
                        if (sel) setState(() => _preferredLanguage = 'kannada');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('English First'),
                      selected: _preferredLanguage == 'english',
                      onSelected: (sel) {
                        if (sel) setState(() => _preferredLanguage = 'english');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.space32),

                PrimaryButton(
                  label: 'Save Business Profile • ಉಳಿಸಿ',
                  icon: Icons.check_circle_rounded,
                  onPressed: _onSave,
                ),
                const SizedBox(height: AppSizes.space20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
