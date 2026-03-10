import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/order_providers.dart';

// re-export StatusChip shared logic — keep it local to avoid cross-feature import
const _kStatusOrder = [
  '待付款',
  '備貨中',
  '韓國處理中',
  '空運回台中',
  '台灣配送中',
  '已完成',
];

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.isWeb(context);
    final orderAsync = ref.watch(orderDetailProvider(orderId));

    Widget body = orderAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('載入失敗', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(orderDetailProvider(orderId)),
              child: const Text('重試'),
            ),
          ],
        ),
      ),
      data: (order) => _OrderDetailContent(order: order, isWeb: isWeb),
    );

    if (isWeb) {
      body = Column(
        children: [const WebNavBarStandalone(), Expanded(child: body)],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text('訂單詳情'),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
      body: body,
    );
  }
}

// ---------------------------------------------------------------------------
// Full content
// ---------------------------------------------------------------------------

class _OrderDetailContent extends StatelessWidget {
  const _OrderDetailContent({required this.order, required this.isWeb});
  final Order order;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final hPad = isWeb ? 24.0 : 16.0;
    final subtotal = order.totalAmount - order.shippingFee;
    final shippingLabel = order.shippingMethod == 'convenience_store'
        ? '超商取貨'
        : '宅配到府';

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header card ──
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderNumber,
                              style: AppTextStyles.titleLarge,
                            ),
                          ),
                          _StatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('yyyy/MM/dd HH:mm')
                            .format(order.createdAt),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Ordered items ──
                _SectionCard(
                  title: '訂購商品',
                  child: Column(
                    children: List.generate(order.items.length, (i) {
                      final item = order.items[i];
                      final name =
                          item.productSnapshot['name'] as String? ?? '商品';
                      final variants = item.productSnapshot['selected_variants']
                          as Map<String, dynamic>?;
                      final variantLabel = variants != null
                          ? variants.values.join('・')
                          : '';
                      final itemTotal = item.unitPrice * item.quantity;

                      return Column(
                        children: [
                          if (i > 0)
                            const Divider(
                              color: AppColors.divider,
                              height: 16,
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    if (variantLabel.isNotEmpty)
                                      Text(
                                        variantLabel,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    Text(
                                      'x${item.quantity}  ×  NT\$ ${item.unitPrice}',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(
                                        color: AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'NT\$ $itemTotal',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Shipping info ──
                _SectionCard(
                  title: '收件資訊',
                  child: Column(
                    children: [
                      _InfoRow(
                        label: '姓名',
                        value: order.addressSnapshot['recipient_name']
                                as String? ??
                            '',
                      ),
                      _InfoRow(
                        label: '電話',
                        value:
                            order.addressSnapshot['phone'] as String? ?? '',
                      ),
                      _InfoRow(
                        label: '地址',
                        value: order.addressSnapshot['address'] as String? ??
                            '',
                      ),
                      _InfoRow(label: '配送方式', value: shippingLabel),
                      if (order.note != null && order.note!.isNotEmpty)
                        _InfoRow(label: '備註', value: order.note!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Amount summary ──
                _SectionCard(
                  title: '金額摘要',
                  child: Column(
                    children: [
                      _AmountRow(label: '商品小計', value: 'NT\$ $subtotal'),
                      const SizedBox(height: 8),
                      _AmountRow(
                        label: '台灣國內運費',
                        value: order.shippingFee == 0
                            ? '免運'
                            : 'NT\$ ${order.shippingFee}',
                        valueColor: order.shippingFee == 0
                            ? AppColors.success
                            : null,
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.divider, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('總計', style: AppTextStyles.titleLarge),
                          Text(
                            'NT\$ ${order.totalAmount}',
                            style: AppTextStyles.price
                                .copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Status timeline ──
                _SectionCard(
                  title: '訂單狀態',
                  child: _StatusTimeline(
                    order: order,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status timeline
// ---------------------------------------------------------------------------

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final logMap = {for (final log in order.statusLogs) log.status: log};
    final currentIndex = _kStatusOrder.indexOf(order.status);

    return Column(
      children: List.generate(_kStatusOrder.length, (i) {
        final statusName = _kStatusOrder[i];
        final log = logMap[statusName];
        final isDone = i <= currentIndex;
        final isCurrent = i == currentIndex;
        final isLast = i == _kStatusOrder.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.primary
                            : AppColors.border,
                        border: Border.all(
                          color: isDone
                              ? AppColors.primary
                              : AppColors.border,
                          width: isCurrent ? 3 : 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              size: 9,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: i < currentIndex
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status label + time
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isDone
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      if (log != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('yyyy/MM/dd HH:mm')
                              .format(log.createdAt),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        if (log.note != null && log.note!.isNotEmpty)
                          Text(
                            log.note!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textHint),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared local widgets
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textHint),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip (duplicated here to avoid cross-feature import)
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  static Color _bg(String s) {
    switch (s) {
      case '待付款':
        return const Color(0xFFFFF3E0);
      case '備貨中':
        return const Color(0xFFE3F2FD);
      case '韓國處理中':
        return const Color(0xFFF3E5F5);
      case '空運回台中':
        return const Color(0xFFE8EAF6);
      case '台灣配送中':
        return const Color(0xFFE0F2F1);
      case '已完成':
        return const Color(0xFFE8F5E9);
      default:
        return AppColors.surface;
    }
  }

  static Color _fg(String s) {
    switch (s) {
      case '待付款':
        return const Color(0xFFE65100);
      case '備貨中':
        return const Color(0xFF1565C0);
      case '韓國處理中':
        return const Color(0xFF6A1B9A);
      case '空運回台中':
        return const Color(0xFF283593);
      case '台灣配送中':
        return const Color(0xFF00695C);
      case '已完成':
        return const Color(0xFF2E7D32);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.bodySmall.copyWith(
          color: _fg(status),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
