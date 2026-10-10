import '../core/utils/quantity_utils.dart';
import 'ingredient.dart';

class ListIngredient {
  final String id;
  final String listId;
  final String ingredientId;
  final String nameKannada;
  final String nameEnglish;
  final String categoryId;
  final double quantity;
  final String unit;
  final String? notes;
  final int displayOrder;

  const ListIngredient({
    required this.id,
    required this.listId,
    required this.ingredientId,
    required this.nameKannada,
    required this.nameEnglish,
    required this.categoryId,
    required this.quantity,
    required this.unit,
    this.notes,
    this.displayOrder = 0,
  });

  factory ListIngredient.fromIngredient(
    Ingredient ingredient, {
    required String id,
    required String listId,
    double quantity = 1.0,
    String? unit,
    String? notes,
    int displayOrder = 0,
  }) {
    return ListIngredient(
      id: id,
      listId: listId,
      ingredientId: ingredient.id,
      nameKannada: ingredient.nameKannada,
      nameEnglish: ingredient.nameEnglish,
      categoryId: ingredient.categoryId,
      quantity: quantity,
      unit: unit ?? ingredient.defaultUnit,
      notes: notes,
      displayOrder: displayOrder,
    );
  }

  ListIngredient copyWith({
    String? id,
    String? listId,
    String? ingredientId,
    String? nameKannada,
    String? nameEnglish,
    String? categoryId,
    double? quantity,
    String? unit,
    String? notes,
    int? displayOrder,
  }) {
    return ListIngredient(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      ingredientId: ingredientId ?? this.ingredientId,
      nameKannada: nameKannada ?? this.nameKannada,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listId': listId,
        'ingredientId': ingredientId,
        'nameKannada': nameKannada,
        'nameEnglish': nameEnglish,
        'categoryId': categoryId,
        'quantity': quantity,
        'unit': unit,
        if (notes != null) 'notes': notes,
        'displayOrder': displayOrder,
      };

  factory ListIngredient.fromJson(Map<String, dynamic> json) => ListIngredient(
        id: json['id'] as String,
        listId: json['listId'] as String? ?? '',
        ingredientId: json['ingredientId'] as String,
        nameKannada: json['nameKannada'] as String? ?? '',
        nameEnglish: json['nameEnglish'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? 'other',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
        unit: json['unit'] as String? ?? 'kg',
        notes: json['notes'] as String?,
        displayOrder: json['displayOrder'] as int? ?? 0,
      );

  String get formattedQuantity => QuantityUtils.formatQuantity(quantity);
  String get formattedWithUnit => QuantityUtils.formatWithUnit(quantity, unit);
  String get displayName => '$nameKannada / $nameEnglish';
}
