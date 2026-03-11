import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar with search field
        SliverAppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          titleSpacing: AppBreakpoints.isWeb(context) ? 24 : 16,
          title: _SearchBar(
            controller: _searchController,
            onChanged: (q) =>
                ref.read(searchQueryProvider.notifier).state = q,
            onClear: () {
              _searchController.clear();
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
        ),

        // Category chips — only on mobile (web uses top nav)
        if (!AppBreakpoints.isWeb(context))
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              loading: () => const SizedBox(height: 48),
              error: (_, _) => const SizedBox(height: 4),
              data: (cats) => _CategoryChips(
                categories: cats,
                selectedId: selectedCategory,
                onSelected: (id) =>
                    ref.read(selectedCategoryProvider.notifier).state = id,
              ),
            ),
          ),

        // Product grid
        productsAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('載入失敗', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(productsProvider),
                    child: const Text('重試'),
                  ),
                ],
              ),
            ),
          ),
          data: (products) {
            if (products.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    '暫無商品',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              );
            }
            // SliverLayoutBuilder gives the real cross-axis width,
            // letting us derive the exact card aspect ratio so the
            // image is always 3:4 with a fixed text area below.
            return SliverLayoutBuilder(
              builder: (context, constraints) {
                final isWeb = AppBreakpoints.isWeb(context);
                final columns = isWeb ? 4 : 2;
                const spacing = 8.0;
                // Web: 24px L+R padding; Mobile: 16px L+R padding
                final hPad = isWeb ? 24.0 : 16.0;
                const textAreaHeight = 60.0; // name (2 lines) + price

                final innerWidth =
                    constraints.crossAxisExtent - hPad * 2;
                final cardWidth =
                    (innerWidth - spacing * (columns - 1)) / columns;
                final cardHeight = cardWidth * 4 / 3 + textAreaHeight;
                final ratio = cardWidth / cardHeight;

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: ratio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar widget
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: '搜尋商品...',
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textHint),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textHint,
                  padding: EdgeInsets.zero,
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category chips
// ---------------------------------------------------------------------------

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length + 1, // +1 for "全部"
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "全部" chip
            final selected = selectedId == null;
            return _chip(
              label: '全部',
              selected: selected,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final selected = selectedId == cat.id;
          return _chip(
            label: cat.name as String,
            selected: selected,
            onTap: () => onSelected(selected ? null : cat.id as String),
          );
        },
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
