import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _ctrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _query = widget.initialQuery!.trim();
      _addToHistory(_query);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(String q) {
    final trimmed = q.trim();
    setState(() => _query = trimmed);
    if (trimmed.isNotEmpty) _addToHistory(trimmed);
  }

  void _addToHistory(String q) {
    ref.read(searchHistoryProvider.notifier).add(q);
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);

    Widget body = _query.isEmpty
        ? _SearchHistoryView(
            onTap: (q) {
              _ctrl.text = q;
              _submit(q);
            },
          )
        : _SearchResultsView(query: _query, isWeb: isWeb);

    final searchField = _SearchField(
      controller: _ctrl,
      onSubmitted: _submit,
      onChanged: (q) {
        if (q.isEmpty && _query.isNotEmpty) setState(() => _query = '');
      },
      onClear: () {
        _ctrl.clear();
        setState(() => _query = '');
      },
    );

    if (isWeb) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const WebNavBarStandalone(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: searchField,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: body,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: searchField,
        titleSpacing: 0,
      ),
      body: body,
    );
  }
}

// ---------------------------------------------------------------------------
// Search input field
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: '搜尋商品...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        isDense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search history
// ---------------------------------------------------------------------------

class _SearchHistoryView extends ConsumerWidget {
  const _SearchHistoryView({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 64, color: theme.dividerColor),
                const SizedBox(height: 16),
                Text(
                  '搜尋您想找的商品',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '最近搜尋',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        ref.read(searchHistoryProvider.notifier).clearAll(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      textStyle: theme.textTheme.bodySmall,
                    ),
                    child: const Text('清除全部'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: history.map((q) {
                  return ActionChip(
                    label: Text(q),
                    onPressed: () => onTap(q),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: theme.textTheme.bodySmall,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Search results
// ---------------------------------------------------------------------------

class _SearchResultsView extends ConsumerWidget {
  const _SearchResultsView({required this.query, required this.isWeb});
  final String query;
  final bool isWeb;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchProductsProvider(query));
    final theme = Theme.of(context);
    final columns = isWeb ? 4 : 2;
    final hPad = isWeb ? 24.0 : 16.0;

    return resultsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text('搜尋失敗：$e', style: theme.textTheme.bodyMedium),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_outlined,
                    size: 64, color: theme.dividerColor),
                const SizedBox(height: 16),
                Text(
                  '找不到「$query」的相關商品',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.52,
          ),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        );
      },
    );
  }
}
