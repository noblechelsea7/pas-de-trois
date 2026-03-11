import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/models/product.dart';
import '../providers/admin_providers.dart';

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
  late final TextEditingController _descCtrl;
  late final TextEditingController _krwPriceCtrl;
  late final TextEditingController _twdPriceCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _domesticFeeCtrl;
  late final TextEditingController _sourceUrlCtrl;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _krwPriceCtrl = TextEditingController(text: p?.krwPrice.toString() ?? '');
    _twdPriceCtrl = TextEditingController(text: p?.twdPrice.toString() ?? '');
    _weightCtrl = TextEditingController(text: p?.weightKg.toString() ?? '');
    _domesticFeeCtrl =
        TextEditingController(text: p?.domesticShippingFee.toString() ?? '0');
    _sourceUrlCtrl = TextEditingController(text: p?.sourceUrl ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _krwPriceCtrl.dispose();
    _twdPriceCtrl.dispose();
    _weightCtrl.dispose();
    _domesticFeeCtrl.dispose();
    _sourceUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
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
      if (_isEdit) {
        await repo.updateProduct(widget.product!.id, data);
      } else {
        await repo.createProduct(data);
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
        constraints: const BoxConstraints(maxWidth: 500),
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
                  _field('商品名稱', _nameCtrl, required: true),
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
                      Expanded(
                        child: _field('台幣價格 (TWD)', _twdPriceCtrl,
                            required: true, isNumber: true),
                      ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _saving ? null : () => Navigator.of(context).pop(),
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
