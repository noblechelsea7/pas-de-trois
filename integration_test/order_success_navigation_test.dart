import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:korea_proxy/core/theme/app_theme.dart';
import 'package:korea_proxy/features/orders/presentation/screens/order_success_screen.dart';
import 'package:korea_proxy/features/products/domain/models/category.dart';
import 'package:korea_proxy/features/products/presentation/providers/product_providers.dart';

const _testOrderId = 'test-order-123';

/// Simple labeled screen for verifying navigation destinations.
class _LabelScreen extends StatelessWidget {
  const _LabelScreen(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(label)));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Supabase with dummy credentials so that
    // Supabase.instance.client.auth.currentSession (used by WebNavBar)
    // doesn't crash. No real network calls are made.
    try {
      await Supabase.initialize(
        url: 'https://test-project.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
            'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoiYW5vbiIs'
            'ImlhdCI6MTYwMDAwMDAwMCwiZXhwIjoxOTAwMDAwMDAwfQ.'
            'dc_FBSgrgBMVYMOp5v6r0aq3WEHfEGgfHbKm3MBYdmY',
      );
    } catch (_) {
      // Already initialized — safe to ignore.
    }
  });

  // -------------------------------------------------------------------
  // Helper: build a self-contained test app with its own GoRouter.
  // No auth redirect, no Supabase data calls (providers overridden).
  // -------------------------------------------------------------------
  GoRouter createTestRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const _LabelScreen('HOME'),
        ),
        GoRoute(
          path: '/products',
          builder: (_, _) => const _LabelScreen('PRODUCTS'),
        ),
        GoRoute(
          path: '/orders',
          builder: (_, _) => const _LabelScreen('ORDERS'),
        ),
        GoRoute(
          path: '/order-success/:orderId',
          builder: (_, state) => OrderSuccessScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ],
    );
  }

  Widget buildTestApp(GoRouter router) {
    return ProviderScope(
      overrides: [
        // Prevent Supabase call for order number lookup.
        orderNumberProvider(_testOrderId)
            .overrideWith((ref) async => 'ORD-TEST-001'),
        // Prevent Supabase call for categories (used by WebNavBarStandalone).
        categoriesProvider.overrideWith((ref) async => <Category>[]),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.lightTheme,
      ),
    );
  }

  // -------------------------------------------------------------------
  // Tests
  // -------------------------------------------------------------------

  group('OrderSuccessScreen navigation', () {
    testWidgets(
      'should_navigate_to_orders_when_tap_查看我的訂單',
      (tester) async {
        final router = createTestRouter('/order-success/$_testOrderId');
        await tester.pumpWidget(buildTestApp(router));
        await tester.pumpAndSettle();

        // Verify we start on the success page.
        expect(find.text('訂單已送出！'), findsOneWidget);

        // Tap the primary button.
        await tester.tap(find.text('查看我的訂單'));
        await tester.pumpAndSettle();

        // Should be on the orders page.
        expect(find.text('ORDERS'), findsOneWidget);
        expect(find.text('訂單已送出！'), findsNothing);
      },
    );

    testWidgets(
      'should_navigate_to_products_when_tap_繼續購物',
      (tester) async {
        final router = createTestRouter('/order-success/$_testOrderId');
        await tester.pumpWidget(buildTestApp(router));
        await tester.pumpAndSettle();

        expect(find.text('訂單已送出！'), findsOneWidget);

        await tester.tap(find.text('繼續購物'));
        await tester.pumpAndSettle();

        expect(find.text('PRODUCTS'), findsOneWidget);
        expect(find.text('訂單已送出！'), findsNothing);
      },
    );

    testWidgets(
      'should_not_return_to_success_page_when_back_navigation',
      (tester) async {
        final router = createTestRouter('/order-success/$_testOrderId');
        await tester.pumpWidget(buildTestApp(router));
        await tester.pumpAndSettle();

        expect(find.text('訂單已送出！'), findsOneWidget);

        // Navigate away via button.
        await tester.tap(find.text('查看我的訂單'));
        await tester.pumpAndSettle();
        expect(find.text('ORDERS'), findsOneWidget);

        // Simulate system back button (triggers PopScope / browser back).
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        // Must NOT return to the success page.
        expect(find.text('訂單已送出！'), findsNothing);
      },
    );

    testWidgets(
      'should_redirect_to_home_when_system_back_on_success_page',
      (tester) async {
        final router = createTestRouter('/order-success/$_testOrderId');
        await tester.pumpWidget(buildTestApp(router));
        await tester.pumpAndSettle();

        expect(find.text('訂單已送出！'), findsOneWidget);

        // Press system back while ON the success page.
        // PopScope(canPop: false) should redirect to home.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('HOME'), findsOneWidget);
        expect(find.text('訂單已送出！'), findsNothing);
      },
    );
  });
}
