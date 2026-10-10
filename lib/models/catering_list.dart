import 'list_ingredient.dart';

class CateringList {
  final String id;
  final String title;
  final String clientName;
  final String? clientPhone;
  final String eventName;
  final DateTime eventDate;
  final String? eventTime;
  final int? guestCount;
  final String? location;
  final String? notes;
  final List<ListIngredient> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CateringList({
    required this.id,
    required this.title,
    required this.clientName,
    this.clientPhone,
    required this.eventName,
    required this.eventDate,
    this.eventTime,
    this.guestCount,
    this.location,
    this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  CateringList copyWith({
    String? id,
    String? title,
    String? clientName,
    String? clientPhone,
    String? eventName,
    DateTime? eventDate,
    String? eventTime,
    int? guestCount,
    String? location,
    String? notes,
    List<ListIngredient>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CateringList(
      id: id ?? this.id,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      eventName: eventName ?? this.eventName,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      guestCount: guestCount ?? this.guestCount,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'eventName': eventName,
        'eventDate': eventDate.toIso8601String(),
        'eventTime': eventTime,
        'guestCount': guestCount,
        'location': location,
        'notes': notes,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CateringList.fromJson(Map<String, dynamic> json) => CateringList(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Untitled List',
        clientName: json['clientName'] as String? ?? '',
        clientPhone: json['clientPhone'] as String?,
        eventName: json['eventName'] as String? ?? '',
        eventDate: json['eventDate'] != null
            ? DateTime.parse(json['eventDate'] as String)
            : DateTime.now(),
        eventTime: json['eventTime'] as String?,
        guestCount: json['guestCount'] as int?,
        location: json['location'] as String?,
        notes: json['notes'] as String?,
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

  int get categoryCount {
    final catIds = items.map((e) => e.categoryId).toSet();
    return catIds.length;
  }

  Map<String, List<ListIngredient>> get groupedByCategory {
    final Map<String, List<ListIngredient>> grouped = {};
    for (final item in items) {
      if (!grouped.containsKey(item.categoryId)) {
        grouped[item.categoryId] = [];
      }
      grouped[item.categoryId]!.add(item);
    }
    return grouped;
  }

  List<String> getValidationErrors() {
    final List<String> errors = [];
    if (clientName.trim().isEmpty) {
      errors.add('Client name is required');
    }
    if (eventName.trim().isEmpty) {
      errors.add('Event name is required');
    }
    if (items.isEmpty) {
      errors.add('Please select at least one ingredient');
    }
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.quantity <= 0) {
        errors.add('${item.displayName} has invalid quantity (${item.quantity})');
      }
      if (item.unit.trim().isEmpty) {
        errors.add('${item.displayName} is missing unit');
      }
    }
    return errors;
  }

  bool get isValid => getValidationErrors().isEmpty;
}
