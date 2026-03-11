import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authRepositoryProvider).signOut();
    if (context.mounted) context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final ordersAsync = ref.watch(userOrdersProvider);
    final profile = profileAsync.valueOrNull;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: CustomScrollView(
      slivers: [
        // ── Gradient header ──
        SliverToBoxAdapter(
          child: profileAsync.when(
            loading: () => _HeaderSkeleton(),
            error: (err, st) => _HeaderSkeleton(),
            data: (p) => _ProfileHeader(profile: p),
          ),
        ),

        // ── Stats bar ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _StatsBar(ordersAsync: ordersAsync),
          ),
        ),

        // ── Order status strip ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _OrderStatusStrip(
              ordersAsync: ordersAsync,
              onTap: () => context.push(RoutePaths.orders),
            ),
          ),
        ),

        // ── Menu ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _MenuSection(
                items: [
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: '我的訂單',
                    onTap: () => context.push(RoutePaths.orders),
                  ),
                  _MenuItem(
                    icon: Icons.location_on_outlined,
                    label: '收件地址',
                    onTap: () => context.push(RoutePaths.profileAddress),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: '關心商品',
                    onTap: () => context.push(RoutePaths.wishlist),
                  ),
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    label: '個人資料編輯',
                    onTap: () => context.push(RoutePaths.profileEdit),
                  ),
                ],
              ),
              if (profile?.isAdmin == true) ...[
                const SizedBox(height: 12),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: '管理後台',
                      labelColor: AppColors.primary,
                      onTap: () => context.go(RoutePaths.adminDashboard),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _signOut(context, ref),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('登出'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gradient header
// ---------------------------------------------------------------------------

class _HeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, AppColors.surface, 0.35)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final dynamic profile; // UserProfile?

  @override
  Widget build(BuildContext context) {
    final initials = (profile?.fullName?.isNotEmpty == true
            ? (profile!.fullName as String)[0]
            : profile?.email?[0] ?? '?')
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 44),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            Color.lerp(AppColors.primary, AppColors.surface, 0.35)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            child: Text(
              initials,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile?.fullName ?? '未設定姓名',
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.email ?? '',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats bar  (總消費 | 訂單數 | 待處理)
// ---------------------------------------------------------------------------

const _kPendingStatuses = {'待付款', '備貨中', '韓國處理中'};

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.ordersAsync});
  final AsyncValue<List<Order>> ordersAsync;

  @override
  Widget build(BuildContext context) {
    final orders = ordersAsync.valueOrNull ?? [];

    final totalSpend = orders
        .where((o) => o.status != 'cancelled')
        .fold<int>(0, (sum, o) => sum + o.totalAmount);
    final totalCount = orders.length;
    final pendingCount = orders
        .where((o) => _kPendingStatuses.contains(o.status))
        .length;

    final formattedSpend = _formatAmount(totalSpend);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(label: '總消費', value: 'NT\$$formattedSpend'),
            _VerticalDivider(),
            _StatCell(label: '訂單數', value: '$totalCount筆'),
            _VerticalDivider(),
            _StatCell(label: '待處理', value: '$pendingCount筆'),
          ],
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.border,
    );
  }
}

// ---------------------------------------------------------------------------
// Order status strip
// ---------------------------------------------------------------------------

const _kStatusIcons = <String, IconData>{
  '待付款': Icons.credit_card_outlined,
  '備貨中': Icons.inventory_2_outlined,
  '韓國處理中': Icons.store_outlined,
  '空運回台中': Icons.flight_outlined,
  '台灣配送中': Icons.local_shipping_outlined,
  '已完成': Icons.check_circle_outline_rounded,
};

class _OrderStatusStrip extends StatelessWidget {
  const _OrderStatusStrip({
    required this.ordersAsync,
    required this.onTap,
  });
  final AsyncValue<List<Order>> ordersAsync;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orders = ordersAsync.valueOrNull ?? [];
    final counts = <String, int>{
      for (final s in kOrderStatuses) s: 0,
    };
    for (final o in orders) {
      if (counts.containsKey(o.status)) {
        counts[o.status] = counts[o.status]! + 1;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: kOrderStatuses.map((status) {
            final count = counts[status]!;
            final active = count > 0;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _kStatusIcons[status] ?? Icons.circle_outlined,
                      size: 22,
                      color: active ? AppColors.primary : AppColors.textHint,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: active ? AppColors.primary : AppColors.textHint,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      status,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9,
                        color: active
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu section
// ---------------------------------------------------------------------------

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.indexed.map((entry) {
          final (i, item) = entry;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                const Divider(height: 1, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final color = labelColor ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
