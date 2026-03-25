import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../utils/app_theme.dart';
import '../screens/add_edit_screen.dart';

class DetailSheet extends StatefulWidget {
  final PasswordEntry entry;
  const DetailSheet({super.key, required this.entry});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  bool _showPassword = false;

  void _copy(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label কপি হয়েছে!'),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = Category.defaults.firstWhere(
      (c) => c.id == widget.entry.category,
      orElse: () => Category.defaults.last,
    );

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppTheme.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(cat.color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.entry.title,
                            style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                        Text(cat.name,
                            style: TextStyle(color: Color(cat.color), fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddEditScreen(entry: widget.entry)));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'ইউজারনেম',
              value: widget.entry.username,
              onCopy: () => _copy(widget.entry.username, 'ইউজারনেম'),
            ),
            _buildDetailRow(
              icon: Icons.lock_outline,
              label: 'পাসওয়ার্ড',
              value: _showPassword
                  ? widget.entry.password
                  : '•' * widget.entry.password.length.clamp(0, 16),
              onCopy: () => _copy(widget.entry.password, 'পাসওয়ার্ড'),
              trailing: IconButton(
                icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            if (widget.entry.website?.isNotEmpty == true)
              _buildDetailRow(
                icon: Icons.language,
                label: 'ওয়েবসাইট',
                value: widget.entry.website!,
                onCopy: () => _copy(widget.entry.website!, 'ওয়েবসাইট'),
              ),
            if (widget.entry.notes?.isNotEmpty == true)
              _buildDetailRow(
                icon: Icons.note_outlined,
                label: 'নোট',
                value: widget.entry.notes!,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded, color: AppTheme.primary, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
