import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/layout/web_nav_bar.dart';
import 'web_history_stub.dart'
    if (dart.library.html) 'web_history_web.dart';

part 'order_success_screen.g.dart';

@riverpod
Future<String?> orderNumber(Ref ref, String orderId) async {
  final data = await Supabase.instance.client
      .from('orders')
      .select('order_number')
      .eq('id', orderId)
      .single();
  return data['order_number'] as String?;
}

class OrderSuccessScreen extends ConsumerStatefulWidget {
  const OrderSuccessScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends ConsumerState<OrderSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final isWeb = AppBreakpoints.isWeb(context);
    final orderNumberAsync = ref.watch(orderNumberProvider(widget.orderId));

    final content = SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 24 : 32,
              vertical: 48,
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text('訂單已送出！', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 12),
                orderNumberAsync.when(
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (number) => number != null
                      ? Text(
                          '訂單編號：$number',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                Text(
                  '我們已收到您的訂單，將盡快為您處理。',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Synchronously replace the current (success) history
                      // entry before GoRouter pushes the next one.
                      // On App this is a no-op (stub).
                      replaceHistoryWithHome();
                      context.go('/orders');
                    },
                    child: const Text('查看我的訂單'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      replaceHistoryWithHome();
                      context.go('/products');
                    },
                    child: const Text('繼續購物'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        // App hardware back button: redirect to home instead of success page.
        if (!didPop && mounted) context.go('/');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isWeb
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
        body: isWeb
            ? Column(
                children: [const WebNavBarStandalone(), Expanded(child: content)])
            : content,
      ),
    );
  }
}
