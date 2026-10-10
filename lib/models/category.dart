class Category {
  final String id;
  final String nameKannada;
  final String nameEnglish;
  final int displayOrder;
  final String? iconName;

  const Category({
    required this.id,
    required this.nameKannada,
    required this.nameEnglish,
    required this.displayOrder,
    this.iconName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameKannada': nameKannada,
        'nameEnglish': nameEnglish,
        'displayOrder': displayOrder,
        if (iconName != null) 'iconName': iconName,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        nameKannada: json['nameKannada'] as String,
        nameEnglish: json['nameEnglish'] as String,
        displayOrder: json['displayOrder'] as int? ?? 0,
        iconName: json['iconName'] as String?,
      );

  String get displayName => '$nameKannada / $nameEnglish';
}
