/// Base URL da API Rooter.
///
/// Emulador Android: use `http://10.0.2.2:8000`
/// iOS Simulator / desktop: `http://127.0.0.1:8000`
/// Device físico: IP da máquina na rede local
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
