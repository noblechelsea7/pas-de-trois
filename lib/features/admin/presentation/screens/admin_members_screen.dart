import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../orders/domain/models/order.dart';
import '../providers/admin_providers.dart';

class AdminMembersScreen extends ConsumerWidget {
  const AdminMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(adminMembersProvider);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('會員管理', style: AppTextStyles.headlineLarge),
              const Spacer(),
              IconButton(
                onPressed: () => ref.invalidate(adminMembersProvider),
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
          Expanded(
            child: membersAsync.when(
              data: (members) => members.isEmpty
                  ? Center(
                      child: Text('目前沒有會員',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary)),
                    )
                  : _MemberList(members: members),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberList extends ConsumerStatefulWidget {
  const _MemberList({required this.members});
  final List<UserProfile> members;

  @override
  ConsumerState<_MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<_MemberList> {
  String? _expandedUserId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: Text('顯示名稱',
                          style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 3,
                      child: Text('Email',
                          style: AppTextStyles.labelLarge)),
                  Expanded(
                      flex: 2,
                      child: Text('註冊時間',
                          style: AppTextStyles.labelLarge)),
                  const SizedBox(
                      width: 80,
                      child:
                          Text('管理員', textAlign: TextAlign.center)),
                  const SizedBox(
                      width: 80,
                      child:
                          Text('狀態', textAlign: TextAlign.center)),
                ],
              ),
            ),
            const Divider(height: 1),
            ...widget.members.map(_buildMemberTile),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(UserProfile member) {
    final isExpanded = _expandedUserId == member.id;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() {
            _expandedUserId = isExpanded ? null : member.id;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.surface,
                  child: Text(
                    (member.fullName?.isNotEmpty == true
                            ? member.fullName![0]
                            : member.email[0])
                        .toUpperCase(),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Text(
                    member.fullName ?? '未設定',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    member.email,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatDate(member.createdAt),
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Switch(
                      value: member.isAdmin,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => _toggleAdmin(member, val),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: _ActiveBadge(
                      isActive: member.isActive,
                      onTap: () =>
                          _toggleActive(member, !member.isActive),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) _MemberDetail(userId: member.id),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _toggleAdmin(UserProfile member, bool isAdmin) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .toggleMemberAdmin(member.id, isAdmin);
      ref.invalidate(adminMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isAdmin
                  ? '${member.email} 已設為管理員'
                  : '${member.email} 已取消管理員')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗：$e')),
        );
      }
    }
  }

  Future<void> _toggleActive(UserProfile member, bool isActive) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .toggleMemberActive(member.id, isActive);
      ref.invalidate(adminMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isActive
                  ? '${member.email} 已啟用'
                  : '${member.email} 已封鎖')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失敗：$e')),
        );
      }
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}

// ---------------------------------------------------------------------------
// Active badge
// ---------------------------------------------------------------------------

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isActive ? '啟用' : '封鎖',
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expanded detail
// ---------------------------------------------------------------------------

class _MemberDetail extends ConsumerStatefulWidget {
  const _MemberDetail({required this.userId});
  final String userId;

  @override
  ConsumerState<_MemberDetail> createState() => _MemberDetailState();
}

class _MemberDetailState extends ConsumerState<_MemberDetail> {
  late final TextEditingController _notesController;
  bool _notesDirty = false;

  @override
  void initState() {
    super.initState();
    final members =
        ref.read(adminMembersProvider).valueOrNull ?? [];
    final member =
        members.where((m) => m.id == widget.userId).firstOrNull;
    _notesController =
        TextEditingController(text: member?.adminNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync =
        ref.watch(memberOrdersProvider(widget.userId));

    return Container(
      color: AppColors.surface.withValues(alpha: 0.4),
      padding: const EdgeInsets.fromLTRB(72, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('歷史訂單',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('尚無訂單記錄',
                      style: AppTextStyles.bodySmall),
                );
              }
              final total = orders.fold<int>(
                  0, (sum, o) => sum + o.totalAmount);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '共 ${orders.length} 筆訂單，總消費 NT\$ $total',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _MiniOrderTable(orders: orders),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('載入訂單失敗：$e'),
          ),
          const SizedBox(height: 20),
          Text('管理員備註',
              style: AppTextStyles.titleLarge
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '輸入備註...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onChanged: (_) {
                    if (!_notesDirty) {
                      setState(() => _notesDirty = true);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _notesDirty ? _saveNotes : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('儲存'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotes() async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .updateAdminNotes(widget.userId, _notesController.text);
      ref.invalidate(adminMembersProvider);
      setState(() => _notesDirty = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('備註已儲存')),
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
// Mini order table
// ---------------------------------------------------------------------------

class _MiniOrderTable extends StatelessWidget {
  const _MiniOrderTable({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surface),
        columnSpacing: 16,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 36,
        headingRowHeight: 36,
        columns: const [
          DataColumn(label: Text('訂單編號')),
          DataColumn(label: Text('日期')),
          DataColumn(label: Text('金額'), numeric: true),
          DataColumn(label: Text('狀態')),
        ],
        rows: orders
            .take(10)
            .map((o) => DataRow(cells: [
                  DataCell(Text(o.orderNumber,
                      style: AppTextStyles.bodySmall)),
                  DataCell(Text(_fmtDate(o.createdAt),
                      style: AppTextStyles.bodySmall)),
                  DataCell(Text('NT\$ ${o.totalAmount}',
                      style: AppTextStyles.bodySmall)),
                  DataCell(Text(o.status,
                      style: AppTextStyles.bodySmall)),
                ]))
            .toList(),
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
}
