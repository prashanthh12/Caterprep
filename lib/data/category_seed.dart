import '../models/category.dart';

class CategorySeed {
  static const List<Category> categories = [
    Category(
      id: 'grains',
      nameKannada: 'ಧಾನ್ಯಗಳು',
      nameEnglish: 'Grains',
      displayOrder: 1,
      iconName: 'grain',
    ),
    Category(
      id: 'pulses',
      nameKannada: 'ಬೇಳೆಗಳು',
      nameEnglish: 'Pulses',
      displayOrder: 2,
      iconName: 'grass',
    ),
    Category(
      id: 'vegetables',
      nameKannada: 'ತರಕಾರಿಗಳು',
      nameEnglish: 'Vegetables',
      displayOrder: 3,
      iconName: 'eco',
    ),
    Category(
      id: 'spices',
      nameKannada: 'ಮಸಾಲೆಗಳು',
      nameEnglish: 'Spices',
      displayOrder: 4,
      iconName: 'whatshot',
    ),
    Category(
      id: 'oils',
      nameKannada: 'ಎಣ್ಣೆಗಳು',
      nameEnglish: 'Oils & Ghee',
      displayOrder: 5,
      iconName: 'opacity',
    ),
    Category(
      id: 'dairy',
      nameKannada: 'ಹಾಲು ಉತ್ಪನ್ನಗಳು',
      nameEnglish: 'Dairy',
      displayOrder: 6,
      iconName: 'local_drink',
    ),
    Category(
      id: 'fruits',
      nameKannada: 'ಹಣ್ಣುಗಳು',
      nameEnglish: 'Fruits & Coconut',
      displayOrder: 7,
      iconName: 'nature',
    ),
    Category(
      id: 'dry_fruits',
      nameKannada: 'ಒಣಹಣ್ಣುಗಳು',
      nameEnglish: 'Dry Fruits & Nuts',
      displayOrder: 8,
      iconName: 'spa',
    ),
    Category(
      id: 'sweets',
      nameKannada: 'ಸಿಹಿ ಪದಾರ್ಥಗಳು',
      nameEnglish: 'Sweet Ingredients',
      displayOrder: 9,
      iconName: 'cake',
    ),
    Category(
      id: 'other',
      nameKannada: 'ಇತರೆ',
      nameEnglish: 'Other Essentials',
      displayOrder: 10,
      iconName: 'inventory_2',
    ),
  ];

  static Category getCategory(String id) {
    return categories.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => const Category(
        id: 'other',
        nameKannada: 'ಇತರೆ',
        nameEnglish: 'Other',
        displayOrder: 99,
      ),
    );
  }
}
