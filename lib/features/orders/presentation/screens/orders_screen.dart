import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/order_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.isWeb(context);
    final ordersAsync = ref.watch(userOrdersProvider);

    Widget body = ordersAsync.when(
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
              onPressed: () => ref.invalidate(userOrdersProvider),
              child: const Text('重試'),
            ),
          ],
        ),
      ),
      data: (orders) {
        if (orders.isEmpty) return _EmptyOrders(isWeb: isWeb);
        return _OrderList(orders: orders, isWeb: isWeb);
      },
    );

    if (isWeb) {
      body = Column(
        children: [
          const WebNavBarStandalone(),
          Expanded(child: body),
        ],
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
              title: const Text('我的訂單'),
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
// Empty state
// ---------------------------------------------------------------------------

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.isWeb});
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            '還沒有訂單',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '快去挑選喜歡的韓國商品吧',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: () => context.go(RoutePaths.products),
              child: const Text('去購物'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order list
// ---------------------------------------------------------------------------

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.isWeb});
  final List orders;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final hPad = isWeb ? 24.0 : 16.0;

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _OrderCard(order: orders[index] as dynamic),
    );
  }
}

// ---------------------------------------------------------------------------
// Order card
// ---------------------------------------------------------------------------

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final dynamic order;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('yyyy/MM/dd HH:mm').format(order.createdAt as DateTime);

    return InkWell(
      onTap: () => context.push('/orders/${order.id}'),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: order number + status chip
            Row(
              children: [
                Text(
                  order.orderNumber as String,
                  style: AppTextStyles.titleMedium,
                ),
                const Spacer(),
                _StatusChip(status: order.status as String),
              ],
            ),
            const SizedBox(height: 8),
            // Date
            Text(
              dateStr,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            // Total + arrow
            Row(
              children: [
                Text(
                  '總金額',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  'NT\$ ${order.totalAmount}',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status chip
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
