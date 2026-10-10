import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/category_seed.dart';
import '../../models/category.dart';
import '../../models/catering_list.dart';
import '../../models/ingredient.dart';
import '../../models/list_ingredient.dart';
import '../../models/template.dart';
import '../../models/user.dart';
import '../../repositories/catering_repository.dart';
import '../../services/local_storage_service.dart';

// Storage & Repository
final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be overridden in main');
});

final repositoryProvider = Provider<CateringRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return CateringRepository(storage);
});

// Category Catalog
final categoriesProvider = Provider<List<Category>>((ref) {
  return CategorySeed.categories;
});

// Business Profile State
class BusinessProfileNotifier extends Notifier<BusinessProfile> {
  @override
  BusinessProfile build() {
    final repo = ref.watch(repositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile(BusinessProfile profile) async {
    state = profile;
    final repo = ref.read(repositoryProvider);
    await repo.saveProfile(profile);
  }
}

final businessProfileProvider =
    NotifierProvider<BusinessProfileNotifier, BusinessProfile>(
  BusinessProfileNotifier.new,
);

// Saved Catering Lists State
class SavedListsNotifier extends Notifier<List<CateringList>> {
  @override
  List<CateringList> build() {
    final repo = ref.watch(repositoryProvider);
    return repo.getSavedLists();
  }

  Future<void> saveList(CateringList list) async {
    final repo = ref.read(repositoryProvider);
    await repo.saveList(list);
    state = repo.getSavedLists();
  }

  Future<void> deleteList(String id) async {
    final repo = ref.read(repositoryProvider);
    await repo.deleteList(id);
    state = repo.getSavedLists();
  }

  Future<CateringList> duplicateList(CateringList original) async {
    const uuid = Uuid();
    final duplicated = original.copyWith(
      id: uuid.v4(),
      title: '${original.title} (Copy)',
      eventName: '${original.eventName} (Copy)',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: original.items
          .map((i) => i.copyWith(id: uuid.v4(), listId: uuid.v4()))
          .toList(),
    );
    await saveList(duplicated);
    return duplicated;
  }
}

final savedListsProvider =
    NotifierProvider<SavedListsNotifier, List<CateringList>>(
  SavedListsNotifier.new,
);

// Templates State
class TemplatesNotifier extends Notifier<List<CateringTemplate>> {
  @override
  List<CateringTemplate> build() {
    final repo = ref.watch(repositoryProvider);
    return repo.getTemplates();
  }

  Future<void> saveTemplate(CateringTemplate template) async {
    final repo = ref.read(repositoryProvider);
    await repo.saveTemplate(template);
    state = repo.getTemplates();
  }

  Future<void> deleteTemplate(String id) async {
    final repo = ref.read(repositoryProvider);
    await repo.deleteTemplate(id);
    state = repo.getTemplates();
  }

  Future<CateringTemplate> createTemplateFromList(
    CateringList list, {
    required String templateName,
    String? description,
  }) async {
    const uuid = Uuid();
    final newTemplate = CateringTemplate(
      id: uuid.v4(),
      name: templateName,
      description: description ?? 'Created from ${list.eventName}',
      guestCount: list.guestCount ?? 100,
      eventType: list.eventName,
      items: list.items,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await saveTemplate(newTemplate);
    return newTemplate;
  }
}

final templatesProvider =
    NotifierProvider<TemplatesNotifier, List<CateringTemplate>>(
  TemplatesNotifier.new,
);

// Ingredients Catalog State (Master + Custom)
class IngredientCatalogNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() {
    final repo = ref.watch(repositoryProvider);
    return repo.getAllIngredients();
  }

  Future<void> addCustomIngredient(Ingredient ingredient) async {
    final repo = ref.read(repositoryProvider);
    await repo.addCustomIngredient(ingredient);
    state = repo.getAllIngredients();
  }
}

final ingredientCatalogProvider =
    NotifierProvider<IngredientCatalogNotifier, List<Ingredient>>(
  IngredientCatalogNotifier.new,
);

// Active Draft / Editing List Notifier
class CurrentDraftListNotifier extends Notifier<CateringList?> {
  @override
  CateringList? build() {
    final repo = ref.watch(repositoryProvider);
    return repo.getDraft();
  }

  void startNewList({CateringTemplate? fromTemplate}) {
    const uuid = Uuid();
    final now = DateTime.now();
    final listId = uuid.v4();

    List<ListIngredient> initialItems = [];
    String eventName = '';
    int? guestCount;

    if (fromTemplate != null) {
      eventName = fromTemplate.name;
      guestCount = fromTemplate.guestCount;
      initialItems = fromTemplate.items.map((item) {
        return item.copyWith(
          id: uuid.v4(),
          listId: listId,
        );
      }).toList();
    }

    state = CateringList(
      id: listId,
      title: eventName.isNotEmpty ? eventName : 'New Catering List',
      clientName: '',
      clientPhone: '',
      eventName: eventName,
      eventDate: now.add(const Duration(days: 3)),
      eventTime: '12:30 PM',
      guestCount: guestCount,
      location: '',
      notes: '',
      items: initialItems,
      createdAt: now,
      updatedAt: now,
    );

    _persistDraft();
  }

  void loadExistingList(CateringList list) {
    state = list;
    _persistDraft();
  }

  void updateClientDetails({
    required String clientName,
    String? clientPhone,
    required String eventName,
    required DateTime eventDate,
    String? eventTime,
    int? guestCount,
    String? location,
    String? notes,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      title: eventName.isNotEmpty ? eventName : '${clientName.trim()}\'s Event',
      clientName: clientName,
      clientPhone: clientPhone,
      eventName: eventName,
      eventDate: eventDate,
      eventTime: eventTime,
      guestCount: guestCount,
      location: location,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _persistDraft();
  }

  void toggleIngredient(Ingredient ingredient) {
    if (state == null) return;
    const uuid = Uuid();
    final items = List<ListIngredient>.from(state!.items);
    final existingIndex =
        items.indexWhere((i) => i.ingredientId == ingredient.id);

    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    } else {
      items.add(
        ListIngredient.fromIngredient(
          ingredient,
          id: uuid.v4(),
          listId: state!.id,
          quantity: 1.0,
          unit: ingredient.defaultUnit,
          displayOrder: items.length + 1,
        ),
      );
    }

    state = state!.copyWith(items: items, updatedAt: DateTime.now());
    _persistDraft();
  }

  void updateItemQuantity(String ingredientId, double newQty) {
    if (state == null || newQty <= 0) return;
    final items = List<ListIngredient>.from(state!.items);
    final idx = items.indexWhere((i) => i.ingredientId == ingredientId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: newQty);
      state = state!.copyWith(items: items, updatedAt: DateTime.now());
      _persistDraft();
    }
  }

  void updateItemUnit(String ingredientId, String unit) {
    if (state == null) return;
    final items = List<ListIngredient>.from(state!.items);
    final idx = items.indexWhere((i) => i.ingredientId == ingredientId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(unit: unit);
      state = state!.copyWith(items: items, updatedAt: DateTime.now());
      _persistDraft();
    }
  }

  void updateItemDetails(ListIngredient updatedItem) {
    if (state == null) return;
    final items = List<ListIngredient>.from(state!.items);
    final idx = items.indexWhere((i) => i.id == updatedItem.id);
    if (idx >= 0) {
      items[idx] = updatedItem;
    } else {
      items.add(updatedItem);
    }
    state = state!.copyWith(items: items, updatedAt: DateTime.now());
    _persistDraft();
  }

  void removeItem(String itemId) {
    if (state == null) return;
    final items = List<ListIngredient>.from(state!.items);
    items.removeWhere((i) => i.id == itemId || i.ingredientId == itemId);
    state = state!.copyWith(items: items, updatedAt: DateTime.now());
    _persistDraft();
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (state == null) return;
    final items = List<ListIngredient>.from(state!.items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state!.copyWith(items: items, updatedAt: DateTime.now());
    _persistDraft();
  }

  Future<void> commitAndSave() async {
    if (state == null) return;
    final repo = ref.read(repositoryProvider);
    final completedList = state!.copyWith(updatedAt: DateTime.now());
    await repo.saveList(completedList);
    await repo.clearDraft();
    ref.read(savedListsProvider.notifier).saveList(completedList);
  }

  void clearDraft() {
    state = null;
    ref.read(repositoryProvider).clearDraft();
  }

  void _persistDraft() {
    if (state != null) {
      ref.read(repositoryProvider).saveDraft(state!);
    }
  }
}

final currentDraftListProvider =
    NotifierProvider<CurrentDraftListNotifier, CateringList?>(
  CurrentDraftListNotifier.new,
);

// UI Filter Notifiers
class IngredientSearchFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final ingredientSearchFilterProvider =
    NotifierProvider<IngredientSearchFilterNotifier, String>(
  IngredientSearchFilterNotifier.new,
);

class SelectedCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? categoryId) => state = categoryId;
}

final selectedCategoryFilterProvider =
    NotifierProvider<SelectedCategoryFilterNotifier, String?>(
  SelectedCategoryFilterNotifier.new,
);

