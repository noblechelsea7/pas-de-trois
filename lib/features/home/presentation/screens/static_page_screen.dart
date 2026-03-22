import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/page_providers.dart';

class StaticPageScreen extends ConsumerWidget {
  const StaticPageScreen({super.key, required this.pageKey});
  final String pageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.isWeb(context);
    final pageAsync = ref.watch(pageByKeyProvider(pageKey));

    Widget body = pageAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(child: Text('載入失敗：$e', style: AppTextStyles.bodyMedium)),
      data: (page) {
        if (page == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.find_in_page_outlined, size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text('頁面不存在', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.fromLTRB(isWeb ? 24 : 16, 24, isWeb ? 24 : 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(page.title, style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 24),
                    MarkdownBody(
                      data: page.content,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTextStyles.bodyMedium.copyWith(height: 1.8),
                        h2: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        h3: AppTextStyles.titleMedium,
                        listBullet: AppTextStyles.bodyMedium,
                        blockquoteDecoration: BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (isWeb) {
      body = Column(children: [const WebNavBarStandalone(), Expanded(child: body)]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
      body: body,
    );
  }
}
