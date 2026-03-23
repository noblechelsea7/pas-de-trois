import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../products/domain/models/product.dart';
import '../../../products/presentation/providers/product_providers.dart';

part 'search_providers.g.dart';

const _historyKey = 'search_history';
const _maxHistory = 10;

@riverpod
Future<List<Product>> searchProducts(Ref ref, String query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.read(productRepositoryProvider).getProducts(query: query.trim());
}

@Riverpod(keepAlive: true)
class SearchHistory extends _$SearchHistory {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(q);
    list.insert(0, q);
    if (list.length > _maxHistory) list.removeLast();
    await prefs.setStringList(_historyKey, list);
    state = AsyncData(list);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    state = const AsyncData([]);
  }
}
