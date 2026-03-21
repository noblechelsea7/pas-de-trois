import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/models/product.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/admin_providers.dart';

const int _kMaxImages = 10;

class AdminProductEditDialog extends ConsumerStatefulWidget {
  const AdminProductEditDialog({
    super.key,
    this.product,
    required this.onSaved,
  });

  final Product? product;
  final VoidCallback onSaved;

  @override
  ConsumerState<AdminProductEditDialog> createState() =>
      _AdminProductEditDialogState();
}

class _AdminProductEditDialogState
    extends ConsumerState<AdminProductEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandNameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _krwPriceCtrl;
  late final TextEditingController _twdPriceCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _domesticFeeCtrl;
  late final TextEditingController _sourceUrlCtrl;

  // Multi-image state
  late List<ProductImage> _existingImages; // images already in DB
  final List<Uint8List> _newImages = []; // newly picked bytes

  bool _saving = false;
  bool _isAutoTwd = true;

  bool get _isEdit => widget.product != null;
  int get _totalImages => _existingImages.length + _newImages.length;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    // Populate images from product
    _existingImages = List.of(p?.images ?? []);
    // If no product_images but image_url exists, create a synthetic entry
    if (_existingImages.isEmpty && p?.imageUrl != null) {
      _existingImages = [
        ProductImage(
          id: '',
          productId: p!.id,
          url: p.imageUrl!,
          sortOrder: 0,
          isPrimary: true,
        ),
      ];
    }

    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _brandNameCtrl = TextEditingController(text: p?.brandName ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _krwPriceCtrl = TextEditingController(text: p?.krwPrice.toString() ?? '');
    _twdPriceCtrl = TextEditingController(text: p?.twdPrice.toString() ?? '');
    _weightCtrl = TextEditingController(text: p?.weightKg.toString() ?? '');
    _domesticFeeCtrl =
        TextEditingController(text: p?.domesticShippingFee.toString() ?? '0');
    _sourceUrlCtrl = TextEditingController(text: p?.sourceUrl ?? '');

    _isAutoTwd = p == null;

    _krwPriceCtrl.addListener(_onKrwChanged);
    _twdPriceCtrl.addListener(_onTwdEdited);
  }

  @override
  void dispose() {
    _krwPriceCtrl.removeListener(_onKrwChanged);
    _twdPriceCtrl.removeListener(_onTwdEdited);
    _nameCtrl.dispose();
    _brandNameCtrl.dispose();
    _descCtrl.dispose();
    _krwPriceCtrl.dispose();
    _twdPriceCtrl.dispose();
    _weightCtrl.dispose();
    _domesticFeeCtrl.dispose();
    _sourceUrlCtrl.dispose();
    super.dispose();
  }

  void _onKrwChanged() {
    if (!_isAutoTwd) return;
    final krw = int.tryParse(_krwPriceCtrl.text.trim());
    if (krw == null || krw == 0) return;
    final settings = ref.read(productSettingsProvider).valueOrNull ?? {};
    final rate = double.tryParse(settings['exchange_rate'] ?? '') ?? 25.0;
    final twd = (krw / rate).round();
    _twdPriceCtrl.removeListener(_onTwdEdited);
    _twdPriceCtrl.text = twd.toString();
    _twdPriceCtrl.addListener(_onTwdEdited);
  }

  void _onTwdEdited() {
    if (_isAutoTwd) {
      final krw = int.tryParse(_krwPriceCtrl.text.trim());
      if (krw != null && krw > 0) {
        final settings = ref.read(productSettingsProvider).valueOrNull ?? {};
        final rate = double.tryParse(settings['exchange_rate'] ?? '') ?? 25.0;
        final autoTwd = (krw / rate).round().toString();
        if (_twdPriceCtrl.text.trim() != autoTwd) {
          setState(() => _isAutoTwd = false);
        }
      }
    }
  }

  Future<void> _pickImages() async {
    if (_totalImages >= _kMaxImages) return;
    final picker = ImagePicker();
    final xfiles = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (xfiles.isEmpty) return;
    final remaining = _kMaxImages - _totalImages;
    final toAdd = xfiles.take(remaining);
    final bytes = await Future.wait(toAdd.map((f) => f.readAsBytes()));
    setState(() => _newImages.addAll(bytes));
  }

  void _removeExisting(int index) =>
      setState(() => _existingImages.removeAt(index));

  void _removeNew(int index) => setState(() => _newImages.removeAt(index));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final brandName = _brandNameCtrl.text.trim();
    final data = {
      'name': _nameCtrl.text.trim(),
      'brand_name': brandName.isEmpty ? null : brandName,
      'description': _descCtrl.text.trim(),
      'krw_price': int.parse(_krwPriceCtrl.text.trim()),
      'twd_price': int.parse(_twdPriceCtrl.text.trim()),
      'weight_kg': double.parse(_weightCtrl.text.trim()),
      'domestic_shipping_fee': int.parse(_domesticFeeCtrl.text.trim()),
      'source_url': _sourceUrlCtrl.text.trim().isEmpty
          ? null
          : _sourceUrlCtrl.text.trim(),
    };

    try {
      final repo = ref.read(adminRepositoryProvider);
      String productId;

      if (_isEdit) {
        await repo.updateProduct(widget.product!.id, data);
        productId = widget.product!.id;
      } else {
        productId = await repo.createProduct(data);
      }

      // Replace all product images if any exist or were modified
      if (_totalImages > 0 ||
          (widget.product?.images.isNotEmpty ?? false) ||
          (widget.product?.imageUrl != null)) {
        await repo.replaceAllProductImages(
          productId,
          _existingImages.map((img) => img.url).toList(),
          _newImages,
        );
      }

      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdit ? '編輯商品' : '新增商品',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 20),

                  // ── Multi-image picker ────────────────────────────────────
                  _MultiImageSection(
                    existingImages: _existingImages,
                    newImages: _newImages,
                    totalImages: _totalImages,
                    maxImages: _kMaxImages,
                    onAdd: _totalImages < _kMaxImages ? _pickImages : null,
                    onRemoveExisting: _removeExisting,
                    onRemoveNew: _removeNew,
                  ),
                  const SizedBox(height: 16),

                  // ── Form fields ───────────────────────────────────────────
                  _field('商品名稱', _nameCtrl, required: true),
                  const SizedBox(height: 12),
                  _field('品牌名稱', _brandNameCtrl),
                  const SizedBox(height: 12),
                  _field('描述', _descCtrl, maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field('韓幣價格 (KRW)', _krwPriceCtrl,
                            required: true, isNumber: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _twdField()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field('重量 (kg)', _weightCtrl,
                            required: true, isDecimal: true),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field('韓國境內運費', _domesticFeeCtrl,
                            isNumber: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _field('來源網址', _sourceUrlCtrl),
                  const SizedBox(height: 24),

                  // ── Actions ───────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 40),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEdit ? '更新' : '建立'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _twdField() {
    return TextFormField(
      controller: _twdPriceCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: '台幣價格 (TWD)',
        suffixText: _isAutoTwd ? '自動換算' : '已自訂',
        suffixStyle: TextStyle(
          fontSize: 11,
          color: _isAutoTwd ? AppColors.success : AppColors.textSecondary,
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? '台幣價格 (TWD) 為必填' : null,
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool isNumber = false,
    bool isDecimal = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber
          ? TextInputType.number
          : isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (isDecimal) FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '$label 為必填' : null
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-image picker section
// ---------------------------------------------------------------------------

class _MultiImageSection extends StatelessWidget {
  const _MultiImageSection({
    required this.existingImages,
    required this.newImages,
    required this.totalImages,
    required this.maxImages,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  final List<ProductImage> existingImages;
  final List<Uint8List> newImages;
  final int totalImages;
  final int maxImages;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('商品圖片', style: AppTextStyles.bodyMedium),
            const SizedBox(width: 8),
            Text(
              '$totalImages / $maxImages',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            if (totalImages > 0) ...[
              const SizedBox(width: 8),
              Text(
                '（第一張為主圖）',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Existing images
              for (int i = 0; i < existingImages.length; i++)
                _ImageTile(
                  isFirst: i == 0 && totalImages > 0,
                  onRemove: () => onRemoveExisting(i),
                  child: CachedNetworkImage(
                    imageUrl: existingImages[i].url,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.surface),
                    errorWidget: (_, _, _) =>
                        Container(color: AppColors.surface),
                  ),
                ),

              // New (pending) images
              for (int i = 0; i < newImages.length; i++)
                _ImageTile(
                  isFirst: existingImages.isEmpty && i == 0,
                  onRemove: () => onRemoveNew(i),
                  child: Image.memory(newImages[i], fit: BoxFit.cover),
                ),

              // Add button
              if (onAdd != null)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 75,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.border, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 24, color: AppColors.textSecondary),
                        SizedBox(height: 4),
                        Text(
                          '新增圖片',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.isFirst,
    required this.onRemove,
    required this.child,
  });

  final bool isFirst;
  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: child,
          ),
          // Primary badge
          if (isFirst)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: const Text(
                  '主圖',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
