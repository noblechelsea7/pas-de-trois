import 'package:intl/intl.dart';

/// Centralized date/time utilities for Supabase timestamptz columns.
///
/// All DB dates are stored in UTC; all UI dates are displayed in local time.
/// Use these methods everywhere instead of manual toUtc()/toLocal() calls.
abstract final class AppDateUtils {
  // ---------------------------------------------------------------------------
  // DB ↔ Dart conversion
  // ---------------------------------------------------------------------------

  /// Dart local DateTime → UTC ISO-8601 string for Supabase storage.
  static String? toDbString(DateTime? dt) =>
      dt?.toUtc().toIso8601String();

  /// UTC ISO-8601 string from Supabase → Dart local DateTime.
  static DateTime? fromDbString(String? s) =>
      s != null ? DateTime.parse(s).toLocal() : null;

  /// Non-nullable variant of [fromDbString].
  static DateTime fromDbStringRequired(String s) =>
      DateTime.parse(s).toLocal();

  /// Current time as UTC ISO-8601 string (for DB queries / writes).
  static String nowToDbString() => DateTime.now().toUtc().toIso8601String();

  // ---------------------------------------------------------------------------
  // UI formatting (input is always local DateTime)
  // ---------------------------------------------------------------------------

  /// Format a local DateTime for display. Returns empty string if null.
  static String format(DateTime? dt, {String pattern = 'yyyy/MM/dd HH:mm'}) =>
      dt != null ? DateFormat(pattern).format(dt) : '';
}
