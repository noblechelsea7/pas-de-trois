/// Compile-time environment variables.
///
/// Values are injected via `--dart-define-from-file=.env.json` (local)
/// or `--dart-define=KEY=VALUE` (CI/CD).
///
/// Copy `.env.example` → `.env.json` and fill in your Supabase credentials
/// before running the app locally.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );
}
