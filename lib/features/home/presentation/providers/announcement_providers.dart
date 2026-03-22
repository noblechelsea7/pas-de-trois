import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/models/announcement.dart';
import '../../../../core/utils/app_date_utils.dart';

part 'announcement_providers.g.dart';

@riverpod
Future<List<Announcement>> activeAnnouncements(Ref ref) async {
  final client = Supabase.instance.client;
  final now = AppDateUtils.nowToDbString();
  final data = await client
      .from('announcements')
      .select()
      .eq('is_published', true)
      .or('starts_at.is.null,starts_at.lte.$now')
      .or('ends_at.is.null,ends_at.gte.$now')
      .order('created_at', ascending: false);
  return (data as List)
      .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<Announcement?> latestActiveAnnouncement(Ref ref) async {
  final client = Supabase.instance.client;
  final now = AppDateUtils.nowToDbString();
  final data = await client
      .from('announcements')
      .select()
      .eq('is_published', true)
      .or('starts_at.is.null,starts_at.lte.$now')
      .or('ends_at.is.null,ends_at.gte.$now')
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();
  if (data == null) return null;
  return Announcement.fromJson(data as Map<String, dynamic>);
}

@riverpod
Future<String?> latestAnnouncementTitle(Ref ref) async {
  final announcements = await ref.watch(activeAnnouncementsProvider.future);
  if (announcements.isEmpty) return null;
  return announcements.first.title;
}

@riverpod
Future<Announcement?> latestAnnouncement(Ref ref) async {
  final announcements = await ref.watch(activeAnnouncementsProvider.future);
  if (announcements.isEmpty) return null;
  return announcements.first;
}
