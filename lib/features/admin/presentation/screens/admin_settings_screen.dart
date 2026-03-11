import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/admin_providers.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(adminSettingsProvider);

    return settingsAsync.when(
      data: (settings) => _SettingsBody(settings: settings),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('載入失敗：$e')),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  const _SettingsBody({required this.settings});
  final Map<String, String> settings;

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  late final TextEditingController _exchangeRate;
  late final TextEditingController _intlShippingRate;
  late final TextEditingController _freeShippingThreshold;
  late final TextEditingController _announcement;

  @override
  void initState() {
    super.initState();
    _exchangeRate = TextEditingController(
        text: widget.settings['exchange_rate'] ?? '25.0');
    _intlShippingRate = TextEditingController(
        text: widget.settings['intl_shipping_rate_per_kg'] ?? '180');
    _freeShippingThreshold = TextEditingController(
        text: widget.settings['free_shipping_threshold'] ?? '3000');
    _announcement = TextEditingController(
        text: widget.settings['announcement_text'] ?? '');
  }

  @override
  void dispose() {
    _exchangeRate.dispose();
    _intlShippingRate.dispose();
    _freeShippingThreshold.dispose();
    _announcement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('系統設定', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    ref.invalidate(adminSettingsProvider),
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

          // All settings in one card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // 1. 匯率
                _SettingRow(
                  title: 'KRW/TWD 匯率',
                  description: '韓幣兌台幣匯率（例：25.0）',
                  field: SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _exchangeRate,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d.]')),
                      ],
                      decoration: InputDecoration(
                        suffixText: 'KRW/TWD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  onSave: () =>
                      _save('exchange_rate', _exchangeRate.text),
                ),
                Divider(height: 1, color: theme.dividerColor),

                // 2. 國際運費
                _SettingRow(
                  title: '國際運費費率',
                  description: '每公斤國際運費，不足 0.5kg 以 0.5kg 計',
                  field: SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _intlShippingRate,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        suffixText: 'TWD/kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  onSave: () => _save('intl_shipping_rate_per_kg',
                      _intlShippingRate.text),
                ),
                Divider(height: 1, color: theme.dividerColor),

                // 3. 免運門檻
                _SettingRow(
                  title: '免運門檻',
                  description: '台灣境內配送免運費門檻',
                  field: SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _freeShippingThreshold,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        suffixText: 'TWD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  onSave: () => _save('free_shipping_threshold',
                      _freeShippingThreshold.text),
                ),
                Divider(height: 1, color: theme.dividerColor),

                // 4. 首頁公告
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '首頁公告',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '顯示在前台首頁，留空則不顯示',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(
                                color: theme
                                    .colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _announcement,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: '輸入公告內容...',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextButton(
                          onPressed: () => _save(
                              'announcement_text',
                              _announcement.text),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                theme.colorScheme.primary,
                          ),
                          child: const Text('儲存'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _save(String key, String value) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateSetting(key, value);
      ref.invalidate(adminSettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定已儲存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Setting row
// ---------------------------------------------------------------------------

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.description,
    required this.field,
    required this.onSave,
  });

  final String title;
  final String description;
  final Widget field;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          field,
          const Spacer(),
          TextButton(
            onPressed: onSave,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }
}
