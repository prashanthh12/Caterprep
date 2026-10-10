import 'list_ingredient.dart';

class CateringTemplate {
  final String id;
  final String name;
  final String description;
  final int guestCount;
  final String eventType;
  final List<ListIngredient> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CateringTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.guestCount,
    required this.eventType,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'guestCount': guestCount,
        'eventType': eventType,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CateringTemplate.fromJson(Map<String, dynamic> json) =>
      CateringTemplate(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        guestCount: json['guestCount'] as int? ?? 100,
        eventType: json['eventType'] as String? ?? 'General Event',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => ListIngredient.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  int get itemCount => items.length;
}
