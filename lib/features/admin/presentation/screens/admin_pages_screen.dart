import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/models/site_page.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_providers.dart';

class AdminPagesScreen extends ConsumerWidget {
  const AdminPagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(adminPagesProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('說明頁管理', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(adminPagesProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '重新整理',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('編輯前台靜態說明頁的標題與內容（支援 Markdown）', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: pagesAsync.when(
              data: (pages) => pages.isEmpty
                  ? Center(child: Text('沒有說明頁', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)))
                  : _PageList(pages: pages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageList extends StatelessWidget {
  const _PageList({required this.pages});
  final List<SitePage> pages;

  static const _keyLabels = {
    'how-to-buy': '購買須知',
    'faq': '常見問題',
    'return-policy': '退換貨政策',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < pages.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _PageRow(page: pages[i], keyLabel: _keyLabels[pages[i].key] ?? pages[i].key),
          ],
        ],
      ),
    );
  }
}

class _PageRow extends ConsumerWidget {
  const _PageRow({required this.page, required this.keyLabel});
  final SitePage page;
  final String keyLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.article_outlined, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(page.key, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: page.isPublished
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              page.isPublished ? '已發布' : '未發布',
              style: AppTextStyles.bodySmall.copyWith(
                color: page.isPublished ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _showEditDialog(context, ref),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('編輯'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _PageEditDialog(page: page, parentRef: ref),
    );
  }
}

class _PageEditDialog extends ConsumerStatefulWidget {
  const _PageEditDialog({required this.page, required this.parentRef});
  final SitePage page;
  final WidgetRef parentRef;

  @override
  ConsumerState<_PageEditDialog> createState() => _PageEditDialogState();
}

class _PageEditDialogState extends ConsumerState<_PageEditDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TabController _tabCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.page.title);
    _contentCtrl = TextEditingController(text: widget.page.content);
    _tabCtrl = TabController(length: 2, vsync: this);
    _contentCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updatePage(
        widget.page.key,
        _titleCtrl.text.trim(),
        _contentCtrl.text,
      );
      widget.parentRef.invalidate(adminPagesProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('說明頁已儲存')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 620),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  Text('編輯說明頁', style: AppTextStyles.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            // Title field
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: '頁面標題',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            // Tab bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: TabBar(
                controller: _tabCtrl,
                tabs: const [Tab(text: '編輯'), Tab(text: '預覽')],
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
              ),
            ),
            // Tab content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // Edit tab
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '輸入 Markdown 內容...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    // Preview tab
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _contentCtrl.text.isEmpty
                          ? Center(child: Text('（無內容）', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)))
                          : Markdown(
                              data: _contentCtrl.text,
                              styleSheet: MarkdownStyleSheet(
                                p: AppTextStyles.bodyMedium.copyWith(height: 1.8),
                                h2: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                h3: AppTextStyles.titleMedium,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('儲存'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
