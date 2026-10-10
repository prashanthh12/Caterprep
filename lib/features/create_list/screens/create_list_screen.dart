import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class CreateListScreen extends ConsumerStatefulWidget {
  final String listId;

  const CreateListScreen({super.key, required this.listId});

  @override
  ConsumerState<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends ConsumerState<CreateListScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _clientNameCtrl;
  late TextEditingController _clientPhoneCtrl;
  late TextEditingController _eventNameCtrl;
  late TextEditingController _eventTimeCtrl;
  late TextEditingController _guestCountCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _notesCtrl;

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(currentDraftListProvider);

    _clientNameCtrl = TextEditingController(text: draft?.clientName ?? '');
    _clientPhoneCtrl = TextEditingController(text: draft?.clientPhone ?? '');
    _eventNameCtrl = TextEditingController(text: draft?.eventName ?? '');
    _eventTimeCtrl = TextEditingController(text: draft?.eventTime ?? '12:30 PM');
    _guestCountCtrl = TextEditingController(
      text: draft?.guestCount != null ? draft!.guestCount.toString() : '',
    );
    _locationCtrl = TextEditingController(text: draft?.location ?? '');
    _notesCtrl = TextEditingController(text: draft?.notes ?? '');

    _selectedDate = draft?.eventDate ?? DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _eventNameCtrl.dispose();
    _eventTimeCtrl.dispose();
    _guestCountCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      final guestCount = int.tryParse(_guestCountCtrl.text.trim());

      ref.read(currentDraftListProvider.notifier).updateClientDetails(
            clientName: _clientNameCtrl.text.trim(),
            clientPhone: _clientPhoneCtrl.text.trim(),
            eventName: _eventNameCtrl.text.trim(),
            eventDate: _selectedDate,
            eventTime: _eventTimeCtrl.text.trim(),
            guestCount: guestCount,
            location: _locationCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
          );

      context.push('/lists/${widget.listId}/items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event & Client Details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.pageHorizontalPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        children: const [
                          Icon(Icons.person_pin_circle_rounded,
                              color: AppColors.primaryGreen, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Client & Event Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Client Name (Required)
                      AppTextField(
                        label: 'Client Name (ಗ್ರಾಹಕರ ಹೆಸರು)',
                        hint: 'e.g. Ramesh Hegde',
                        controller: _clientNameCtrl,
                        isRequired: true,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: (v) =>
                            Validators.requiredField(v, 'Client Name'),
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Phone Number (Optional)
                      AppTextField(
                        label: 'Phone Number (ಮೊಬೈಲ್ ಸಂಖ್ಯೆ)',
                        hint: 'e.g. 98450 12345 (for WhatsApp sharing)',
                        controller: _clientPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: Validators.optionalPhoneNumber,
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Event Name (Required)
                      AppTextField(
                        label: 'Event / Occasion Name (ಕಾರ್ಯಕ್ರಮದ ಹೆಸರು)',
                        hint: 'e.g. Wedding Reception Lunch / ಗೃಹಪ್ರವೇಶ',
                        controller: _eventNameCtrl,
                        isRequired: true,
                        prefixIcon: const Icon(Icons.celebration_outlined),
                        validator: (v) =>
                            Validators.requiredField(v, 'Event Name'),
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Date & Time Row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                              child: IgnorePointer(
                                child: AppTextField(
                                  label: 'Event Date *',
                                  hint: AppDateUtils.formatDisplayDate(_selectedDate),
                                  initialValue: AppDateUtils.formatDisplayDate(_selectedDate),
                                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                                  readOnly: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.space12),
                          Expanded(
                            child: AppTextField(
                              label: 'Event Time',
                              hint: '12:30 PM',
                              controller: _eventTimeCtrl,
                              prefixIcon: const Icon(Icons.access_time_rounded),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Guest Count
                      AppTextField(
                        label: 'Guest Count (ಅಂದಾಜು ಜನರ ಸಂಖ್ಯೆ)',
                        hint: 'e.g. 450 (Recommended)',
                        controller: _guestCountCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.people_outline_rounded),
                        validator: Validators.optionalGuestCount,
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Location / Venue
                      AppTextField(
                        label: 'Venue / Location (ಸ್ಥಳ)',
                        hint: 'e.g. Gayatri Vihar Palace Grounds, Bengaluru',
                        controller: _locationCtrl,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      const SizedBox(height: AppSizes.space16),

                      // Special Notes
                      AppTextField(
                        label: 'Catering Notes / Requirements (ವಿಶೇಷ ಸೂಚನೆಗಳು)',
                        hint: 'e.g. Traditional banana leaf meal, no onion/garlic, extra sweets',
                        controller: _notesCtrl,
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                      const SizedBox(height: AppSizes.space24),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom CTA Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pageHorizontalPadding,
                vertical: AppSizes.space16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: 'Select Ingredients • ಸಾಮಾನುಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ',
                icon: Icons.arrow_forward_rounded,
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
