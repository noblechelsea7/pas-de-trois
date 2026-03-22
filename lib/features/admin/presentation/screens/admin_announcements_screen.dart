import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/announcement.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/admin_providers.dart';

class AdminAnnouncementsScreen extends ConsumerWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(adminAnnouncementsProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('公告管理', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(adminAnnouncementsProvider),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: '重新整理',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showEditDialog(context, ref, null),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('新增公告'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: announcementsAsync.when(
              data: (items) => items.isEmpty
                  ? Center(
                      child: Text('目前沒有公告',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)))
                  : _AnnouncementList(items: items),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('載入失敗：$e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Announcement? existing) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _AnnouncementEditDialog(existing: existing, parentRef: ref),
    );
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

class _AnnouncementList extends ConsumerWidget {
  const _AnnouncementList({required this.items});
  final List<Announcement> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Container(
              color: AppColors.surface,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Text('標題', style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 2,
                      child: Text('狀態', style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 3,
                      child: Text('有效期間', style: AppTextStyles.labelLarge)),
                  const SizedBox(width: 120),
                ],
              ),
            ),
            const Divider(height: 1),
            ...items.map((a) => _AnnouncementRow(announcement: a)),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementRow extends ConsumerWidget {
  const _AnnouncementRow({required this.announcement});
  final Announcement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('yy/MM/dd HH:mm');
    String dateRange = '無限制';
    if (announcement.startsAt != null || announcement.endsAt != null) {
      final start = announcement.startsAt != null
          ? fmt.format(announcement.startsAt!.toLocal())
          : '—';
      final end =
          announcement.endsAt != null ? fmt.format(announcement.endsAt!.toLocal()) : '—';
      dateRange = '$start ～ $end';
    }

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Title
              Expanded(
                flex: 4,
                child: Text(announcement.title,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
              ),
              // Published toggle
              Expanded(
                flex: 2,
                child: _PublishedChip(
                  isPublished: announcement.isPublished,
                  onToggle: () => _toggle(ref),
                ),
              ),
              // Date range
              Expanded(
                flex: 3,
                child: Text(dateRange,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ),
              // Actions
              SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _showEdit(context, ref),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: '編輯',
                      color: AppColors.textSecondary,
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      tooltip: '刪除',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _toggle(WidgetRef ref) async {
    await ref
        .read(adminRepositoryProvider)
        .toggleAnnouncementPublished(announcement.id, !announcement.isPublished);
    ref.invalidate(adminAnnouncementsProvider);
  }

  void _showEdit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _AnnouncementEditDialog(existing: announcement, parentRef: ref),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('刪除公告'),
        content:
            Text('確定要刪除「${announcement.title}」？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(adminRepositoryProvider)
                  .deleteAnnouncement(announcement.id);
              ref.invalidate(adminAnnouncementsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }
}

class _PublishedChip extends StatelessWidget {
  const _PublishedChip({required this.isPublished, required this.onToggle});
  final bool isPublished;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isPublished
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublished
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 12,
              color: isPublished
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
            const SizedBox(width: 4),
            Text(
              isPublished ? '已發布' : '未發布',
              style: AppTextStyles.bodySmall.copyWith(
                color: isPublished
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE65100),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit / Create dialog
// ---------------------------------------------------------------------------

class _AnnouncementEditDialog extends ConsumerStatefulWidget {
  const _AnnouncementEditDialog(
      {required this.existing, required this.parentRef});
  final Announcement? existing;
  final WidgetRef parentRef;

  @override
  ConsumerState<_AnnouncementEditDialog> createState() =>
      _AnnouncementEditDialogState();
}

class _AnnouncementEditDialogState
    extends ConsumerState<_AnnouncementEditDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late bool _isPublished;
  DateTime? _startsAt;
  DateTime? _endsAt;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _contentCtrl = TextEditingController(text: a?.content ?? '');
    _isPublished = a?.isPublished ?? false;
    _startsAt = a?.startsAt;
    _endsAt = a?.endsAt;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context,
      {required bool isStart}) async {
    final current = isStart ? _startsAt : _endsAt;
    final initial = current ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : isStart
              ? const TimeOfDay(hour: 0, minute: 0)
              : const TimeOfDay(hour: 23, minute: 59),
    );
    if (pickedTime == null) return;
    setState(() {
      final dt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          pickedTime.hour, pickedTime.minute);
      if (isStart) {
        _startsAt = dt;
      } else {
        _endsAt = dt;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('請輸入公告標題')));
      return;
    }
    setState(() => _saving = true);
    try {
      final data = {
        'title': title,
        'content': _contentCtrl.text,
        'is_published': _isPublished,
        'starts_at': _startsAt?.toIso8601String(),
        'ends_at': _endsAt?.toIso8601String(),
      };
      if (_isEdit) {
        await ref
            .read(adminRepositoryProvider)
            .updateAnnouncement(widget.existing!.id, data);
      } else {
        await ref.read(adminRepositoryProvider).createAnnouncement(data);
      }
      widget.parentRef.invalidate(adminAnnouncementsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? '公告已更新' : '公告已新增')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('儲存失敗：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd HH:mm');
    final contentHeight =
        (MediaQuery.sizeOf(context).height * 0.85 - 200).clamp(220.0, 380.0);

    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Text(_isEdit ? '編輯公告' : '新增公告',
              style: AppTextStyles.titleLarge),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            iconSize: 20,
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        height: contentHeight,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: '公告標題 *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              // Content
              TextField(
                controller: _contentCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: '公告內容',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              // Published toggle
              Row(
                children: [
                  Switch(
                    value: _isPublished,
                    onChanged: (v) => setState(() => _isPublished = v),
                    activeThumbColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(_isPublished ? '已發布' : '草稿（未發布）',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              // Date range
              Text('有效期間（可選）',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: '開始日期',
                      value: _startsAt != null ? fmt.format(_startsAt!) : null,
                      onTap: () => _pickDateTime(context, isStart: true),
                      onClear: _startsAt != null
                          ? () => setState(() => _startsAt = null)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: '結束日期',
                      value: _endsAt != null ? fmt.format(_endsAt!) : null,
                      onTap: () => _pickDateTime(context, isStart: false),
                      onClear: _endsAt != null
                          ? () => setState(() => _endsAt = null)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 100,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? '更新' : '新增'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear_rounded,
                    size: 16, color: AppColors.textHint),
              ),
          ],
        ),
      ),
    );
  }
}
