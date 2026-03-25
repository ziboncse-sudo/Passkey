import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../services/password_provider.dart';
import '../utils/app_theme.dart';
import '../screens/add_edit_screen.dart';
import 'detail_sheet.dart';

class PasswordCard extends StatelessWidget {
  final PasswordEntry entry;
  const PasswordCard({super.key, required this.entry});

  Color _getCategoryColor() {
    final cat = Category.defaults.firstWhere(
      (c) => c.id == entry.category,
      orElse: () => Category.defaults.last,
    );
    return Color(cat.color);
  }

  String _getCategoryIcon() {
    final cat = Category.defaults.firstWhere(
      (c) => c.id == entry.category,
      orElse: () => Category.defaults.last,
    );
    return cat.icon;
  }

  void _copyPassword(BuildContext context) {
    Clipboard.setData(ClipboardData(text: entry.password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('পাসওয়ার্ড কপি হয়েছে!'),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditScreen(entry: entry)),
              ),
              backgroundColor: AppTheme.primary.withOpacity(0.8),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'সম্পাদনা',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) => _confirmDelete(context),
              backgroundColor: AppTheme.danger.withOpacity(0.8),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'মুছুন',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DetailSheet(entry: entry),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(_getCategoryIcon(), style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(entry.username,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyPassword(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('মুছে ফেলবেন?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('"${entry.title}" চিরতরে মুছে যাবে।',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<PasswordProvider>().deletePassword(entry.id!);
    }
  }
}
