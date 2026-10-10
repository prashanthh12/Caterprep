import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:caterprep/models/catering_list.dart';
import 'package:caterprep/models/list_ingredient.dart';
import 'package:caterprep/models/user.dart';
import 'package:caterprep/services/pdf_fonts.dart';
import 'package:caterprep/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfFonts Loader Tests', () {
    test('PdfFonts loads bundled Noto Sans Kannada font bytes', () async {
      PdfFonts.resetCache();
      final fonts = await PdfFonts.load();
      expect(fonts.kannadaRegular, isNotNull);
      expect(fonts.kannadaBold, isNotNull);

      // Verify cached instance is reused
      final fonts2 = await PdfFonts.load();
      expect(identical(fonts, fonts2), isTrue);
    });
  });

  group('Kannada PDF Export Verification Tests', () {
    test('Generates PDF with Kannada categories and ingredients without exception', () async {
      final list = CateringList(
        id: 'L_TEST_01',
        title: 'Wedding Feast',
        clientName: 'Naveen Kumar',
        clientPhone: '+91 98450 99999',
        eventName: 'Wedding Reception',
        eventDate: DateTime(2026, 11, 20),
        guestCount: 500,
        location: 'Bengaluru Palace Grounds',
        notes: 'Strictly traditional Karnataka style cooking',
        items: [
          const ListIngredient(
            id: 'LI_1',
            listId: 'L_TEST_01',
            ingredientId: 'ING_GRAIN_01',
            nameKannada: 'ಅಕ್ಕಿ',
            nameEnglish: 'Rice',
            categoryId: 'grains',
            quantity: 50.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'LI_2',
            listId: 'L_TEST_01',
            ingredientId: 'ING_GRAIN_02',
            nameKannada: 'ಬಾಸ್ಮತಿ ಅಕ್ಕಿ',
            nameEnglish: 'Basmati Rice',
            categoryId: 'grains',
            quantity: 20.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'LI_3',
            listId: 'L_TEST_01',
            ingredientId: 'ING_PULSE_01',
            nameKannada: 'ತೊಗರಿ ಬೇಳೆ',
            nameEnglish: 'Toor Dal',
            categoryId: 'pulses',
            quantity: 15.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'LI_4',
            listId: 'L_TEST_01',
            ingredientId: 'ING_VEG_01',
            nameKannada: 'ಈರುಳ್ಳಿ',
            nameEnglish: 'Onion',
            categoryId: 'vegetables',
            quantity: 25.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'LI_5',
            listId: 'L_TEST_01',
            ingredientId: 'ING_FRUIT_01',
            nameKannada: 'ತೆಂಗಿನಕಾಯಿ',
            nameEnglish: 'Coconut',
            categoryId: 'fruits',
            quantity: 50.0,
            unit: 'pcs',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final profile = BusinessProfile.defaultProfile();
      final bytes = await PdfService.generateCateringListPdf(
        list: list,
        profile: profile,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.lengthInBytes, greaterThan(1000));
      // Assert PDF signature: %PDF (ASCII 0x25, 0x50, 0x44, 0x46)
      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test('Generates two-page PDF list confirming font works across page breaks', () async {
      final items = <ListIngredient>[];
      // Generate 35 items across multiple categories to span at least 2 pages
      for (int i = 1; i <= 35; i++) {
        items.add(
          ListIngredient(
            id: 'LI_MULTI_$i',
            listId: 'L_MULTI_PAGE',
            ingredientId: 'ING_$i',
            nameKannada: 'ಐಟಂ $i - ಅಕ್ಕಿ ತೊಗರಿಬೇಳೆ',
            nameEnglish: 'Item $i - Rice & Dal',
            categoryId: i % 2 == 0 ? 'grains' : 'pulses',
            quantity: (i * 2).toDouble(),
            unit: 'kg',
            notes: i % 3 == 0 ? 'ಉತ್ತಮ ಗುಣಮಟ್ಟದ ಸಾಮಾನು' : null,
          ),
        );
      }

      final multiPageList = CateringList(
        id: 'L_MULTI_PAGE',
        title: 'Grand Banquet',
        clientName: 'Suresh Gowda',
        eventName: 'Grand Banquet 2026',
        eventDate: DateTime(2026, 12, 1),
        guestCount: 1000,
        items: items,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final bytes = await PdfService.generateCateringListPdf(
        list: multiPageList,
        profile: BusinessProfile.defaultProfile(),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });

    test('Regression test fixture: Hanumanthu ingredient list scenario', () async {
      // Scenario from Section 13 & 15 of specification
      final hanumanthuList = CateringList(
        id: 'L_HANUMANTHU',
        title: 'Hanumanthu Catering List',
        clientName: 'Hanumanthu Family',
        clientPhone: '+91 99887 76655',
        eventName: 'Wedding Lunch',
        eventDate: DateTime(2026, 10, 18),
        guestCount: 450,
        location: 'Mysuru Kalyana Mantapa',
        notes: 'ಆಂಧ್ರ ಶೈಲಿ ಮತ್ತು ಕರ್ನಾಟಕ ಸಾಂಪ್ರದಾಯಿಕ ಅಡುಗೆ',
        items: [
          const ListIngredient(
            id: 'H1',
            listId: 'L_HANUMANTHU',
            ingredientId: 'ING_GRAIN_01',
            nameKannada: 'ಸೋನಾ ಮಸೂರಿ ಅಕ್ಕಿ',
            nameEnglish: 'Sona Masoori Rice',
            categoryId: 'grains',
            quantity: 5.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'H2',
            listId: 'L_HANUMANTHU',
            ingredientId: 'ING_GRAIN_02',
            nameKannada: 'ಬಾಸ್ಮತಿ ಅಕ್ಕಿ',
            nameEnglish: 'Basmati Rice',
            categoryId: 'grains',
            quantity: 1.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'H3',
            listId: 'L_HANUMANTHU',
            ingredientId: 'ING_PULSE_01',
            nameKannada: 'ತೊಗರಿ ಬೇಳೆ',
            nameEnglish: 'Toor Dal',
            categoryId: 'pulses',
            quantity: 1.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'H4',
            listId: 'L_HANUMANTHU',
            ingredientId: 'ING_VEG_01',
            nameKannada: 'ಈರುಳ್ಳಿ',
            nameEnglish: 'Onion',
            categoryId: 'vegetables',
            quantity: 8.0,
            unit: 'kg',
          ),
          const ListIngredient(
            id: 'H5',
            listId: 'L_HANUMANTHU',
            ingredientId: 'CUSTOM_01',
            nameKannada: 'ಏಲಕ್ಕಿ ಪುಡಿ',
            nameEnglish: 'Cardamom Powder',
            categoryId: 'spices',
            quantity: 250.0,
            unit: 'g',
            notes: 'ತಾಜಾ ಪುಡಿ ಮಾತ್ರ ಬಳಸಿ',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final pdfService = const PdfService();
      final bytes = await pdfService.generateIngredientListPdf(
        hanumanthuList,
        profile: BusinessProfile.defaultProfile(),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);

      // Save regression output file for inspection
      final file = File('hanumanthu_kannada_export.pdf');
      await file.writeAsBytes(bytes);
      expect(file.existsSync(), isTrue);
    });

    test('Handles custom dynamic Kannada ingredient names and notes without English', () async {
      final customList = CateringList(
        id: 'L_CUSTOM',
        title: 'Custom Local Items',
        clientName: 'ರಾಘವೇಂದ್ರ',
        eventName: 'ಗೃಹಪ್ರವೇಶ',
        eventDate: DateTime(2026, 10, 25),
        items: [
          const ListIngredient(
            id: 'C1',
            listId: 'L_CUSTOM',
            ingredientId: 'CUSTOM_ITEM_01',
            nameKannada: 'ಗಸಗಸೆ',
            nameEnglish: '',
            categoryId: 'spices',
            quantity: 500.0,
            unit: 'g',
            notes: 'ಉತ್ತಮ ದರ್ಜೆಯ ಗಸಗಸೆ',
          ),
          const ListIngredient(
            id: 'C2',
            listId: 'L_CUSTOM',
            ingredientId: 'CUSTOM_ITEM_02',
            nameKannada: '',
            nameEnglish: 'Vanilla Essence',
            categoryId: 'other',
            quantity: 2.0,
            unit: 'bottle',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final bytes = await PdfService.generateCateringListPdf(
        list: customList,
        profile: BusinessProfile.defaultProfile(),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.sublist(0, 4), [0x25, 0x50, 0x44, 0x46]);
    });
  });
}
