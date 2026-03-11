import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/models/product.dart';
import '../providers/admin_providers.dart';
import 'admin_product_edit_screen.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(adminProductsProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('商品管理', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(adminProductsProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '重新整理',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showProductDialog(context, ref),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('新增商品'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: productsAsync.when(
              data: (products) => products.isEmpty
                  ? Center(
                      child: Text('目前沒有商品',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    )
                  : _ProductTable(products: products),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref,
      {Product? product}) {
    showDialog(
      context: context,
      builder: (_) => AdminProductEditDialog(
        product: product,
        onSaved: () => ref.invalidate(adminProductsProvider),
      ),
    );
  }
}

class _ProductTable extends ConsumerWidget {
  const _ProductTable({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surface),
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('商品名稱')),
            DataColumn(label: Text('韓幣價格'), numeric: true),
            DataColumn(label: Text('台幣價格'), numeric: true),
            DataColumn(label: Text('狀態')),
            DataColumn(label: Text('操作')),
          ],
          rows:
              products.map((p) => _buildRow(context, ref, p)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(
      BuildContext context, WidgetRef ref, Product product) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(
              product.name,
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text('₩ ${product.krwPrice}',
            style: AppTextStyles.bodyMedium)),
        DataCell(Text('NT\$ ${product.twdPrice}',
            style: AppTextStyles.priceSmall)),
        DataCell(
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: product.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.textHint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.isActive ? '上架中' : '已下架',
              style: AppTextStyles.bodySmall.copyWith(
                color: product.isActive
                    ? AppColors.success
                    : AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              tooltip: '編輯',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AdminProductEditDialog(
                    product: product,
                    onSaved: () =>
                        ref.invalidate(adminProductsProvider),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                product.isActive
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
              ),
              tooltip: product.isActive ? '下架' : '上架',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                try {
                  await ref
                      .read(adminRepositoryProvider)
                      .toggleProductActive(
                          product.id, !product.isActive);
                  ref.invalidate(adminProductsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(product.isActive
                            ? '${product.name} 已下架'
                            : '${product.name} 已上架'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('操作失敗：$e')),
                    );
                  }
                }
              },
            ),
          ],
        )),
      ],
    );
  }
}
