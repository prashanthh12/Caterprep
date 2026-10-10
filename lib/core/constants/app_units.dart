class UnitDefinition {
  final String code;
  final String display;
  final String displayKannada;
  final String description;
  final double defaultStep;

  const UnitDefinition({
    required this.code,
    required this.display,
    required this.displayKannada,
    required this.description,
    this.defaultStep = 1.0,
  });
}

class AppUnits {
  static const List<UnitDefinition> allUnits = [
    UnitDefinition(
      code: 'kg',
      display: 'kg',
      displayKannada: 'ಕೆ.ಜಿ',
      description: 'Bulk solids',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'g',
      display: 'g',
      displayKannada: 'ಗ್ರಾಂ',
      description: 'Small-weight solids',
      defaultStep: 50.0,
    ),
    UnitDefinition(
      code: 'L',
      display: 'L',
      displayKannada: 'ಲೀಟರ್',
      description: 'Liquids',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'ml',
      display: 'ml',
      displayKannada: 'ಮಿ.ಲೀ',
      description: 'Small liquid quantities',
      defaultStep: 100.0,
    ),
    UnitDefinition(
      code: 'pcs',
      display: 'pcs',
      displayKannada: 'ಪೀಸ್',
      description: 'Countable items',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'packet',
      display: 'packet',
      displayKannada: 'ಪ್ಯಾಕೆಟ್',
      description: 'Packaged items',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'box',
      display: 'box',
      displayKannada: 'ಬಾಕ್ಸ್',
      description: 'Boxed goods',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'bunch',
      display: 'bunch',
      displayKannada: 'ಕಟ್ಟು',
      description: 'Leafy vegetables/herbs',
      defaultStep: 1.0,
    ),
    UnitDefinition(
      code: 'dozen',
      display: 'dozen',
      displayKannada: 'ಡಜನ್',
      description: 'Count by 12',
      defaultStep: 1.0,
    ),
  ];

  static List<String> get unitCodes => allUnits.map((u) => u.code).toList();

  static UnitDefinition getUnit(String code) {
    return allUnits.firstWhere(
      (u) => u.code.toLowerCase() == code.toLowerCase(),
      orElse: () => allUnits.first,
    );
  }
}
