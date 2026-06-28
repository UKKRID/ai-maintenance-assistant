import '../models/user_model.dart';
import '../../../services/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      '/api/auth/register',
      body: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'username': username,
        'phone': phone,
      },
    );
    return AuthResponseModel.fromJson(response);
  }

  Future<TokenResponseModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/api/auth/refresh',
      body: {
        'refresh_token': refreshToken,
      },
    );
    return TokenResponseModel.fromJson(response);
  }

  Future<void> logout(String token) async {
    await _apiClient.post(
      '/api/auth/logout',
      body: {},
    );
  }

  Future<UserModel> getCurrentUser(String token) async {
    final response = await _apiClient.get('/api/auth/me');
    return UserModel.fromJson(response);
  }
}
