import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/site_page.dart';

part 'page_providers.g.dart';

@riverpod
Future<SitePage?> pageByKey(Ref ref, String key) async {
  final client = Supabase.instance.client;
  final data = await client
      .from('pages')
      .select()
      .eq('key', key)
      .maybeSingle();
  if (data == null) return null;
  return SitePage.fromJson(data);
}
