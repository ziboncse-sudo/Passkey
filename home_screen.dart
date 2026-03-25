import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../services/password_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/password_card.dart';
import '../widgets/category_chip.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PasswordProvider>().loadPasswords();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider),
            _buildCategories(provider),
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : provider.passwords.isEmpty
                      ? _buildEmpty()
                      : _buildPasswordList(provider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('নতুন পাসওয়ার্ড'),
      ),
    );
  }

  Widget _buildHeader(PasswordProvider provider) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _showSearch
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: provider.setSearch,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'খুঁজুন...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () {
                      setState(() => _showSearch = false);
                      _searchCtrl.clear();
                      provider.setSearch('');
                    },
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('পাসওয়ার্ড ভল্ট',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          )),
                      Text('${provider.totalCount}টি পাসওয়ার্ড সংরক্ষিত',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    onPressed: () => setState(() => _showSearch = true),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock, color: AppTheme.primary, size: 20),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategories(PasswordProvider provider) {
    final counts = provider.categoryCounts;
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: Category.defaults.length,
        itemBuilder: (_, i) {
          final cat = Category.defaults[i];
          return CategoryChipWidget(
            category: cat,
            count: counts[cat.id] ?? 0,
            isSelected: provider.selectedCategory == cat.id,
            onTap: () => provider.setCategory(cat.id),
          );
        },
      ),
    );
  }

  Widget _buildPasswordList(PasswordProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: provider.passwords.length,
      itemBuilder: (_, i) => PasswordCard(entry: provider.passwords[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_open_rounded, color: AppTheme.primary, size: 50),
          ),
          const SizedBox(height: 20),
          const Text('কোনো পাসওয়ার্ড নেই',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('"নতুন পাসওয়ার্ড" বাটন দিয়ে যোগ করুন',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
