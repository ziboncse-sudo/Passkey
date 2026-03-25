import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

class PasswordProvider extends ChangeNotifier {
  List<PasswordEntry> _passwords = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = false;

  List<PasswordEntry> get passwords => _filteredPasswords();
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  int get totalCount => _passwords.length;

  List<PasswordEntry> _filteredPasswords() {
    var list = _passwords;
    if (_selectedCategory != 'all') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
          p.title.toLowerCase().contains(q) ||
          p.username.toLowerCase().contains(q) ||
          (p.website?.toLowerCase().contains(q) ?? false)).toList();
    }
    return list;
  }

  Map<String, int> get categoryCounts {
    final map = <String, int>{'all': _passwords.length};
    for (final cat in Category.defaults.skip(1)) {
      map[cat.id] = _passwords.where((p) => p.category == cat.id).length;
    }
    return map;
  }

  Future<void> loadPasswords() async {
    _isLoading = true;
    notifyListeners();
    final entries = await DatabaseService.getAllPasswords();
    _passwords = entries.map((e) => e.copyWith(
      password: EncryptionService.decrypt(e.password),
    )).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPassword(PasswordEntry entry) async {
    final id = const Uuid().v4();
    final encrypted = entry.copyWith(
      id: id,
      password: EncryptionService.encrypt(entry.password),
    );
    await DatabaseService.insertPassword(encrypted);
    _passwords.insert(0, entry.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updatePassword(PasswordEntry entry) async {
    final encrypted = entry.copyWith(
      password: EncryptionService.encrypt(entry.password),
    );
    await DatabaseService.updatePassword(encrypted);
    final idx = _passwords.indexWhere((p) => p.id == entry.id);
    if (idx != -1) {
      _passwords[idx] = entry;
      notifyListeners();
    }
  }

  Future<void> deletePassword(String id) async {
    await DatabaseService.deletePassword(id);
    _passwords.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
