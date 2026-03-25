import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../services/encryption_service.dart';
import '../services/password_provider.dart';
import '../utils/app_theme.dart';

class AddEditScreen extends StatefulWidget {
  final PasswordEntry? entry;
  const AddEditScreen({super.key, this.entry});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _notesCtrl;
  late String _selectedCategory;
  bool _obscurePassword = true;
  int _passwordStrength = 0;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _usernameCtrl = TextEditingController(text: e?.username ?? '');
    _passwordCtrl = TextEditingController(text: e?.password ?? '');
    _websiteCtrl = TextEditingController(text: e?.website ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _selectedCategory = e?.category ?? 'other';
    if (e?.password.isNotEmpty == true) {
      _passwordStrength = EncryptionService.calculateStrength(e!.password);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String val) {
    setState(() => _passwordStrength = EncryptionService.calculateStrength(val));
  }

  void _generatePassword() {
    final pass = EncryptionService.generatePassword();
    _passwordCtrl.text = pass;
    _onPasswordChanged(pass);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PasswordProvider>();
    final entry = PasswordEntry(
      id: widget.entry?.id,
      title: _titleCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      category: _selectedCategory,
      website: _websiteCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    if (_isEditing) {
      await provider.updatePassword(entry);
    } else {
      await provider.addPassword(entry);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'পাসওয়ার্ড সম্পাদনা' : 'নতুন পাসওয়ার্ড'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('সংরক্ষণ',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField(_titleCtrl, 'শিরোনাম *', Icons.title, required: true),
            const SizedBox(height: 16),
            _buildField(_usernameCtrl, 'ইউজারনেম / ইমেইল *', Icons.person, required: true),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 8),
            _buildStrengthBar(),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildField(_websiteCtrl, 'ওয়েবসাইট (ঐচ্ছিক)', Icons.language),
            const SizedBox(height: 16),
            _buildField(_notesCtrl, 'নোট (ঐচ্ছিক)', Icons.note, maxLines: 3),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _save, child: Text(_isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন')),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      ),
      validator: required ? (v) => v == null || v.trim().isEmpty ? 'এটি পূরণ করা আবশ্যক' : null : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      onChanged: _onPasswordChanged,
      style: const TextStyle(color: AppTheme.textPrimary, letterSpacing: 2),
      decoration: InputDecoration(
        labelText: 'পাসওয়ার্ড *',
        prefixIcon: const Icon(Icons.lock, color: AppTheme.textSecondary, size: 20),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textSecondary, size: 20),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.primary, size: 20),
              onPressed: _generatePassword,
              tooltip: 'পাসওয়ার্ড তৈরি করুন',
            ),
          ],
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'পাসওয়ার্ড দিন' : null,
    );
  }

  Widget _buildStrengthBar() {
    final colors = AppTheme.strengthColors;
    final label = EncryptionService.strengthLabel(_passwordStrength);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < _passwordStrength ? colors[_passwordStrength] : AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        if (_passwordCtrl.text.isNotEmpty)
          Text(label, style: TextStyle(color: colors[_passwordStrength], fontSize: 12)),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final cats = Category.defaults.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ক্যাটাগরি', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((cat) {
            final selected = _selectedCategory == cat.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.divider,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(cat.name,
                        style: TextStyle(
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
