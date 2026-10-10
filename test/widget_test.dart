import 'package:flutter_test/flutter_test.dart';
import 'package:caterprep/core/utils/quantity_utils.dart';
import 'package:caterprep/core/utils/validators.dart';
import 'package:caterprep/data/category_seed.dart';
import 'package:caterprep/data/ingredient_seed.dart';
import 'package:caterprep/data/template_seed.dart';
import 'package:caterprep/models/catering_list.dart';
import 'package:caterprep/models/list_ingredient.dart';

void main() {
  group('Quantity Utils Tests', () {
    test('Formats integers without decimals', () {
      expect(QuantityUtils.formatQuantity(2.0), '2');
      expect(QuantityUtils.formatQuantity(15.0), '15');
    });

    test('Formats decimals cleanly', () {
      expect(QuantityUtils.formatQuantity(2.5), '2.5');
      expect(QuantityUtils.formatQuantity(2.25), '2.25');
    });

    test('Increments and decrements properly for kg', () {
      expect(QuantityUtils.increment(2.0, 'kg'), 3.0);
      expect(QuantityUtils.decrement(3.0, 'kg'), 2.0);
      // decrement doesn't drop below step
      expect(QuantityUtils.decrement(1.0, 'kg'), 1.0);
    });

    test('Increments and decrements properly for g', () {
      expect(QuantityUtils.increment(100.0, 'g'), 150.0);
      expect(QuantityUtils.decrement(150.0, 'g'), 100.0);
    });
  });

  group('Validators Tests', () {
    test('Required field validation', () {
      expect(Validators.requiredField('', 'Client Name'), 'Client Name is required');
      expect(Validators.requiredField('  ', 'Event Name'), 'Event Name is required');
      expect(Validators.requiredField('Wedding Lunch', 'Event Name'), isNull);
    });

    test('Guest count validation', () {
      expect(Validators.optionalGuestCount(null), isNull);
      expect(Validators.optionalGuestCount(''), isNull);
      expect(Validators.optionalGuestCount('0'), 'Enter a valid guest count (greater than 0)');
      expect(Validators.optionalGuestCount('-5'), 'Enter a valid guest count (greater than 0)');
      expect(Validators.optionalGuestCount('450'), isNull);
    });

    test('Custom item name validation', () {
      expect(Validators.customItemName(kannada: '', english: ''),
          'Please enter either English or Kannada name');
      expect(Validators.customItemName(kannada: 'ಅಕ್ಕಿ', english: ''), isNull);
      expect(Validators.customItemName(kannada: '', english: 'Rice'), isNull);
    });
  });

  group('Bilingual Ingredient Search Tests', () {
    test('Finds rice by English, Kannada and transliterated keyword', () {
      final rice = IngredientSeed.ingredients.firstWhere((i) => i.id == 'ING_GRAIN_01');
      expect(rice.matchesQuery('rice'), isTrue);
      expect(rice.matchesQuery('ಅಕ್ಕಿ'), isTrue);
      expect(rice.matchesQuery('akki'), isTrue);
      expect(rice.matchesQuery('wheat'), isFalse);
    });

    test('Finds onion by eerulli', () {
      final onion = IngredientSeed.ingredients.firstWhere((i) => i.id == 'ING_VEG_01');
      expect(onion.matchesQuery('onion'), isTrue);
      expect(onion.matchesQuery('ಈರುಳ್ಳಿ'), isTrue);
      expect(onion.matchesQuery('eerulli'), isTrue);
    });
  });

  group('CateringList Model & Validation Tests', () {
    test('Validates required fields and ingredients', () {
      final incompleteList = CateringList(
        id: 'L1',
        title: '',
        clientName: '',
        eventName: '',
        eventDate: DateTime.now(),
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final errors = incompleteList.getValidationErrors();
      expect(errors.contains('Client name is required'), isTrue);
      expect(errors.contains('Event name is required'), isTrue);
      expect(errors.contains('Please select at least one ingredient'), isTrue);
      expect(incompleteList.isValid, isFalse);
    });

    test('Complete list passes validation', () {
      final validList = CateringList(
        id: 'L2',
        title: 'Wedding',
        clientName: 'Naveen Sharma',
        eventName: 'Wedding Reception',
        eventDate: DateTime.now(),
        items: [
          const ListIngredient(
            id: 'LI1',
            listId: 'L2',
            ingredientId: 'ING_GRAIN_01',
            nameKannada: 'ಅಕ್ಕಿ',
            nameEnglish: 'Rice',
            categoryId: 'grains',
            quantity: 20.0,
            unit: 'kg',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(validList.isValid, isTrue);
      expect(validList.itemCount, 1);
      expect(validList.categoryCount, 1);
    });
  });

  group('Template Seeds Verification', () {
    test('Contains standard initial templates', () {
      expect(TemplateSeed.initialTemplates.length, greaterThanOrEqualTo(4));
      final wedding = TemplateSeed.initialTemplates.first;
      expect(wedding.name.contains('Wedding'), isTrue);
      expect(wedding.items.length, greaterThanOrEqualTo(6));
    });

    test('Initial 10 Categories are present', () {
      expect(CategorySeed.categories.length, 10);
      expect(CategorySeed.categories.any((c) => c.id == 'grains'), isTrue);
      expect(CategorySeed.categories.any((c) => c.id == 'pulses'), isTrue);
      expect(CategorySeed.categories.any((c) => c.id == 'vegetables'), isTrue);
      expect(CategorySeed.categories.any((c) => c.id == 'spices'), isTrue);
    });
  });
}
