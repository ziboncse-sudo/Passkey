class PasswordEntry {
  final String? id;
  final String title;
  final String username;
  final String password;
  final String category;
  final String? website;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.category,
    this.website,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'category': category,
      'website': website ?? '',
      'notes': notes ?? '',
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      category: map['category'],
      website: map['website'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? category,
    String? website,
    String? notes,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String icon;
  final int color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<Category> defaults = [
    Category(id: 'all', name: 'সব', icon: '🗂️', color: 0xFF6C63FF),
    Category(id: 'social', name: 'সোশ্যাল মিডিয়া', icon: '📱', color: 0xFF4267B2),
    Category(id: 'email', name: 'ইমেইল', icon: '📧', color: 0xFFEA4335),
    Category(id: 'banking', name: 'ব্যাংকিং', icon: '🏦', color: 0xFF00B09B),
    Category(id: 'work', name: 'কাজ', icon: '💼', color: 0xFFFF6B6B),
    Category(id: 'shopping', name: 'শপিং', icon: '🛍️', color: 0xFFFF9F43),
    Category(id: 'other', name: 'অন্যান্য', icon: '🔑', color: 0xFF778CA3),
  ];
}
