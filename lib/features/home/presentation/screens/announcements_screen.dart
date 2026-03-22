import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/layout/web_nav_bar.dart';
import '../../../../core/models/announcement.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/announcement_providers.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeb = AppBreakpoints.isWeb(context);
    final announcementsAsync = ref.watch(activeAnnouncementsProvider);

    Widget body = announcementsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) =>
          Center(child: Text('載入失敗：$e', style: AppTextStyles.bodyMedium)),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.campaign_outlined,
                    size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text('目前沒有公告',
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    isWeb ? 24 : 16, 24, isWeb ? 24 : 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('公告欄', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 24),
                    ...items.map((a) => _AnnouncementCard(announcement: a)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (isWeb) {
      body = Column(
          children: [const WebNavBarStandalone(), Expanded(child: body)]);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text('公告欄'),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
            ),
      body: body,
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd').format(announcement.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text(announcement.title, style: AppTextStyles.titleLarge)),
              Text(dateStr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          if (announcement.content.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Text(announcement.content,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
          ],
        ],
      ),
    );
  }
}
