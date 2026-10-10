import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/ingredient_seed.dart';
import '../data/template_seed.dart';
import '../models/catering_list.dart';
import '../models/ingredient.dart';
import '../models/template.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String _keyLists = 'caterprep_saved_lists';
  static const String _keyDraft = 'caterprep_draft_list';
  static const String _keyTemplates = 'caterprep_templates';
  static const String _keyCustomIngredients = 'caterprep_custom_ingredients';
  static const String _keyProfile = 'caterprep_business_profile';
  static const String _keyInitialized = 'caterprep_initialized_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._seedInitialDataIfNeeded();
    return service;
  }

  Future<void> _seedInitialDataIfNeeded() async {
    final isInitialized = _prefs.getBool(_keyInitialized) ?? false;
    if (!isInitialized) {
      // Seed initial templates
      final initialTemplates = TemplateSeed.initialTemplates;
      await saveTemplates(initialTemplates);

      // Seed a sample saved list so dashboard isn't completely bare on day 1
      final sampleList = CateringList(
        id: 'DEMO_LIST_01',
        title: 'Sharma Family Wedding Lunch',
        clientName: 'Naveen Sharma',
        clientPhone: '+91 98451 98765',
        eventName: 'Wedding Reception Lunch',
        eventDate: DateTime.now().add(const Duration(days: 12)),
        eventTime: '12:30 PM',
        guestCount: 450,
        location: 'Gayatri Vihar Palace Grounds, Bengaluru',
        notes: 'High priority wedding catering. Extra ghee and sweets requested.',
        items: initialTemplates.first.items,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      await saveLists([sampleList]);

      // Seed default business profile
      await saveProfile(BusinessProfile.defaultProfile());

      await _prefs.setBool(_keyInitialized, true);
    }
  }

  // --- Catering Lists ---
  List<CateringList> getLists() {
    final raw = _prefs.getString(_keyLists);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList
          .map((item) => CateringList.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLists(List<CateringList> lists) async {
    final raw = jsonEncode(lists.map((l) => l.toJson()).toList());
    await _prefs.setString(_keyLists, raw);
  }

  Future<void> saveList(CateringList list) async {
    final lists = getLists();
    final index = lists.indexWhere((l) => l.id == list.id);
    if (index >= 0) {
      lists[index] = list;
    } else {
      lists.insert(0, list);
    }
    await saveLists(lists);
  }

  Future<void> deleteList(String id) async {
    final lists = getLists();
    lists.removeWhere((l) => l.id == id);
    await saveLists(lists);
  }

  // --- Draft List ---
  CateringList? getDraft() {
    final raw = _prefs.getString(_keyDraft);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CateringList.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(CateringList draft) async {
    await _prefs.setString(_keyDraft, jsonEncode(draft.toJson()));
  }

  Future<void> clearDraft() async {
    await _prefs.remove(_keyDraft);
  }

  // --- Templates ---
  List<CateringTemplate> getTemplates() {
    final raw = _prefs.getString(_keyTemplates);
    if (raw == null || raw.isEmpty) return TemplateSeed.initialTemplates;
    try {
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList
          .map((item) => CateringTemplate.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return TemplateSeed.initialTemplates;
    }
  }

  Future<void> saveTemplates(List<CateringTemplate> templates) async {
    final raw = jsonEncode(templates.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyTemplates, raw);
  }

  Future<void> saveTemplate(CateringTemplate template) async {
    final templates = getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.insert(0, template);
    }
    await saveTemplates(templates);
  }

  Future<void> deleteTemplate(String id) async {
    final templates = getTemplates();
    templates.removeWhere((t) => t.id == id);
    await saveTemplates(templates);
  }

  // --- Custom Ingredients ---
  List<Ingredient> getCustomIngredients() {
    final raw = _prefs.getString(_keyCustomIngredients);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
      return jsonList
          .map((item) => Ingredient.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomIngredient(Ingredient ingredient) async {
    final list = getCustomIngredients();
    final index = list.indexWhere((i) => i.id == ingredient.id);
    if (index >= 0) {
      list[index] = ingredient;
    } else {
      list.insert(0, ingredient);
    }
    final raw = jsonEncode(list.map((i) => i.toJson()).toList());
    await _prefs.setString(_keyCustomIngredients, raw);
  }

  List<Ingredient> getAllIngredients() {
    final custom = getCustomIngredients();
    final master = IngredientSeed.ingredients;
    // Combine custom ingredients first, then master
    return [...custom, ...master];
  }

  // --- Business Profile ---
  BusinessProfile getProfile() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null || raw.isEmpty) return BusinessProfile.defaultProfile();
    try {
      return BusinessProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return BusinessProfile.defaultProfile();
    }
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }
}
