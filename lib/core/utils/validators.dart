class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? optionalGuestCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return 'Enter a valid guest count (greater than 0)';
    }
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final qty = double.tryParse(value.trim());
    if (qty == null || qty <= 0) {
      return 'Quantity must be greater than 0';
    }
    return null;
  }

  static String? customItemName({String? kannada, String? english}) {
    final hasKannada = kannada != null && kannada.trim().isNotEmpty;
    final hasEnglish = english != null && english.trim().isNotEmpty;
    if (!hasKannada && !hasEnglish) {
      return 'Please enter either English or Kannada name';
    }
    return null;
  }

  static String? optionalPhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }
}
