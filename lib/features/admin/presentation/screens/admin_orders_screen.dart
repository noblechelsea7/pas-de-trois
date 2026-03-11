import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../orders/domain/models/order.dart';
import '../providers/admin_providers.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('訂單管理', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(adminOrdersProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '重新整理',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ordersAsync.when(
              data: (orders) => orders.isEmpty
                  ? Center(
                      child: Text('目前沒有訂單',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    )
                  : _OrderList(orders: orders),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable order list
// ---------------------------------------------------------------------------

class _OrderList extends ConsumerStatefulWidget {
  const _OrderList({required this.orders});
  final List<Order> orders;

  @override
  ConsumerState<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends ConsumerState<_OrderList> {
  String? _expandedOrderId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const SizedBox(width: 24), // expand icon space
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 3,
                      child: Text('訂單編號',
                          style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 2,
                      child: Text('建立時間',
                          style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 2,
                      child: Text('金額',
                          style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 2,
                      child: Text('狀態',
                          style: AppTextStyles.labelLarge)),
                ],
              ),
            ),
            const Divider(height: 1),
            ...widget.orders.map(_buildOrderTile),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(Order order) {
    final isExpanded = _expandedOrderId == order.id;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            _expandedOrderId = isExpanded ? null : order.id;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            child: Row(
              children: [
                // Expand icon
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                // Order number
                Expanded(
                  flex: 3,
                  child: Text(order.orderNumber,
                      style: AppTextStyles.bodyMedium),
                ),
                // Date
                Expanded(
                  flex: 2,
                  child: Text(_formatDate(order.createdAt),
                      style: AppTextStyles.bodySmall),
                ),
                // Amount
                Expanded(
                  flex: 2,
                  child: Text('NT\$ ${order.totalAmount}',
                      style: AppTextStyles.priceSmall),
                ),
                // Status dropdown
                Expanded(
                  flex: 2,
                  child: _StatusDropdown(
                    order: order,
                    onChanged: (newStatus) =>
                        _updateStatus(order, newStatus),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) _OrderDetail(order: order),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _updateStatus(Order order, String newStatus) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateOrderStatus(order.id, newStatus);
      ref.invalidate(adminOrdersProvider);
      ref.invalidate(pendingOrderCountProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '訂單 ${order.orderNumber} 狀態已更新為 $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗：$e')),
        );
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Expanded order detail
// ---------------------------------------------------------------------------

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final addr = order.addressSnapshot;

    return Container(
      color: AppColors.surface.withValues(alpha: 0.4),
      padding: const EdgeInsets.fromLTRB(56, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 商品明細 ---
          Text('商品明細',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (order.items.isEmpty)
            Text('無商品資料', style: AppTextStyles.bodySmall)
          else
            _ItemsTable(items: order.items),

          const SizedBox(height: 20),

          // --- 收件人資訊 + 備註（並排） ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 收件人
              Expanded(
                child: _InfoBlock(
                  title: '收件人資訊',
                  rows: [
                    _InfoRow('姓名',
                        addr['recipient_name']?.toString() ?? '—'),
                    _InfoRow(
                        '電話', addr['phone']?.toString() ?? '—'),
                    _InfoRow('地址',
                        addr['address']?.toString() ?? '—'),
                    _InfoRow(
                        '配送方式',
                        order.shippingMethod == 'home_delivery'
                            ? '宅配'
                            : '超商取貨'),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 備註
              Expanded(
                child: _InfoBlock(
                  title: '備註',
                  rows: [
                    _InfoRow('',
                        order.note?.isNotEmpty == true
                            ? order.note!
                            : '（無備註）'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Items table
// ---------------------------------------------------------------------------

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface),
        columnSpacing: 16,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 36,
        headingRowHeight: 36,
        columns: const [
          DataColumn(label: Text('商品名稱')),
          DataColumn(label: Text('數量'), numeric: true),
          DataColumn(label: Text('單價'), numeric: true),
          DataColumn(label: Text('小計'), numeric: true),
        ],
        rows: items.map((item) {
          final name =
              item.productSnapshot['name']?.toString() ?? '已刪除商品';
          final subtotal = item.unitPrice * item.quantity;
          return DataRow(cells: [
            DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(name,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            DataCell(Text('${item.quantity}',
                style: AppTextStyles.bodySmall)),
            DataCell(Text('NT\$ ${item.unitPrice}',
                style: AppTextStyles.bodySmall)),
            DataCell(Text('NT\$ $subtotal',
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w600))),
          ]);
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info block (title + key-value rows)
// ---------------------------------------------------------------------------

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.rows});
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.label.isNotEmpty) ...[
                      SizedBox(
                        width: 60,
                        child: Text(r.label,
                            style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary)),
                      ),
                    ],
                    Expanded(
                      child: Text(r.value,
                          style: AppTextStyles.bodySmall),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
}

// ---------------------------------------------------------------------------
// Status dropdown
// ---------------------------------------------------------------------------

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.order, required this.onChanged});
  final Order order;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(order.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: order.status,
        underline: const SizedBox.shrink(),
        isDense: true,
        isExpanded: true,
        style: AppTextStyles.bodyMedium,
        icon: Icon(Icons.expand_more_rounded,
            size: 18, color: _statusColor(order.status)),
        items: kOrderStatuses
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s,
                      style: TextStyle(color: _statusColor(s))),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null && value != order.status) {
            onChanged(value);
          }
        },
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      '待付款' => AppColors.statusPending,
      '備貨中' => AppColors.statusPreparing,
      '韓國處理中' => AppColors.statusKorea,
      '空運回台中' => AppColors.statusAir,
      '台灣配送中' => AppColors.statusDelivering,
      '已完成' => AppColors.statusCompleted,
      _ => AppColors.textPrimary,
    };
  }
}
