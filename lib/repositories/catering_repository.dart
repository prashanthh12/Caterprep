import '../models/catering_list.dart';
import '../models/ingredient.dart';
import '../models/template.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';

class CateringRepository {
  final LocalStorageService _storage;

  CateringRepository(this._storage);

  // Lists
  List<CateringList> getSavedLists() => _storage.getLists();

  Future<void> saveList(CateringList list) => _storage.saveList(list);

  Future<void> deleteList(String id) => _storage.deleteList(id);

  CateringList? getDraft() => _storage.getDraft();

  Future<void> saveDraft(CateringList draft) => _storage.saveDraft(draft);

  Future<void> clearDraft() => _storage.clearDraft();

  // Templates
  List<CateringTemplate> getTemplates() => _storage.getTemplates();

  Future<void> saveTemplate(CateringTemplate template) =>
      _storage.saveTemplate(template);

  Future<void> deleteTemplate(String id) => _storage.deleteTemplate(id);

  // Ingredients
  List<Ingredient> getAllIngredients() => _storage.getAllIngredients();

  Future<void> addCustomIngredient(Ingredient ingredient) =>
      _storage.saveCustomIngredient(ingredient);

  // Profile
  BusinessProfile getProfile() => _storage.getProfile();

  Future<void> saveProfile(BusinessProfile profile) =>
      _storage.saveProfile(profile);
}
