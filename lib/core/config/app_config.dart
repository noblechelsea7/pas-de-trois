/// Compile-time environment variables.
///
/// Values are injected via `--dart-define-from-file=.env.json` (local)
/// or `--dart-define=KEY=VALUE` (CI/CD).
///
/// Copy `.env.example` → `.env.json` and fill in your project credentials
/// before running the app locally.
abstract final class AppConfig {
  static const supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
}
