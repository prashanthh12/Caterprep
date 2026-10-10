class Ingredient {
  final String id;
  final String nameKannada;
  final String nameEnglish;
  final String categoryId;
  final String defaultUnit;
  final List<String> searchKeywords;
  final bool isCustom;

  const Ingredient({
    required this.id,
    required this.nameKannada,
    required this.nameEnglish,
    required this.categoryId,
    required this.defaultUnit,
    required this.searchKeywords,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameKannada': nameKannada,
        'nameEnglish': nameEnglish,
        'categoryId': categoryId,
        'defaultUnit': defaultUnit,
        'searchKeywords': searchKeywords,
        'isCustom': isCustom,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json['id'] as String,
        nameKannada: json['nameKannada'] as String? ?? '',
        nameEnglish: json['nameEnglish'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? 'other',
        defaultUnit: json['defaultUnit'] as String? ?? 'kg',
        searchKeywords: (json['searchKeywords'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [],
        isCustom: json['isCustom'] as bool? ?? false,
      );

  String get displayName => '$nameKannada / $nameEnglish';

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    final cleanQuery = query.trim().toLowerCase();

    if (nameEnglish.toLowerCase().contains(cleanQuery)) return true;
    if (nameKannada.contains(cleanQuery)) return true;

    for (final kw in searchKeywords) {
      if (kw.toLowerCase().contains(cleanQuery)) return true;
    }
    return false;
  }
}
