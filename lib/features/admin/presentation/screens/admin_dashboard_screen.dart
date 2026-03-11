import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayOrders = ref.watch(todayOrderCountProvider);
    final pendingOrders = ref.watch(pendingOrderCountProvider);
    final totalMembers = ref.watch(totalMemberCountProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('管理總覽', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 24),

          // Stat cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long_rounded,
                  label: '今日訂單',
                  value: todayOrders,
                  color: AppColors.statusPreparing,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_actions_rounded,
                  label: '待處理訂單',
                  value: pendingOrders,
                  color: AppColors.statusPending,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.people_rounded,
                  label: '總會員數',
                  value: totalMembers,
                  color: AppColors.statusKorea,
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),
          Text('快速連結', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),

          // Quick links
          Row(
            children: [
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.receipt_long_rounded,
                  label: '訂單管理',
                  subtitle: '查看與管理所有訂單',
                  onTap: () => context.go(RoutePaths.adminOrders),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.inventory_2_rounded,
                  label: '商品管理',
                  subtitle: '新增、編輯商品資訊',
                  onTap: () => context.go(RoutePaths.adminProducts),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.people_rounded,
                  label: '會員管理',
                  subtitle: '管理會員帳號與權限',
                  onTap: () => context.go(RoutePaths.adminMembers),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.settings_rounded,
                  label: '系統設定',
                  subtitle: '匯率、運費、公告',
                  onTap: () => context.go(RoutePaths.adminSettings),
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
// Stat card — distinct color per card, gradient from base color
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final AsyncValue<int> value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Build a gradient from a lighter to darker shade of the base color
    final lighterColor = Color.lerp(color, AppColors.white, 0.15)!;
    final darkerColor = Color.lerp(color, AppColors.black, 0.1)!;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lighterColor, darkerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white, size: 24),
          ),
          const SizedBox(height: 18),
          value.when(
            data: (v) => Text(
              '$v',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.white,
                fontSize: 36,
              ),
            ),
            loading: () => const SizedBox(
              height: 36,
              width: 36,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            error: (_, _) => Text(
              '--',
              style: AppTextStyles.displayLarge.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick link card
// ---------------------------------------------------------------------------

class _QuickLinkCard extends StatelessWidget {
  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        hoverColor: AppColors.surface,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 14),
              Text(label, style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
