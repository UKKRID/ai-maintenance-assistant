import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    FlutterSecureStorage? secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Token storage keys
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserFullName = 'user_full_name';
  static const _keyUserRole = 'user_role';

  String? _accessToken;
  UserModel? _currentUser;

  String? get accessToken => _accessToken;
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      _accessToken = result.accessToken;
      _currentUser = result.user;

      // Persist tokens
      await _saveTokens(result);

      return result;
    } catch (e) {
      throw AuthException(message: 'เข้าสู่ระบบไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    String? username,
    String? phone,
  }) async {
    try {
      final result = await _remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
        phone: phone,
      );

      _accessToken = result.accessToken;
      _currentUser = result.user;

      // Persist tokens
      await _saveTokens(result);

      return result;
    } catch (e) {
      throw AuthException(message: 'สมัครสมาชิกไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> refreshToken() async {
    final storedRefreshToken = await _secureStorage.read(key: _keyRefreshToken);
    if (storedRefreshToken == null) {
      throw AuthException(message: 'ไม่มี Refresh Token');
    }

    try {
      final result = await _remoteDataSource.refreshToken(storedRefreshToken);
      _accessToken = result.accessToken;

      // Update stored access token
      await _secureStorage.write(key: _keyAccessToken, value: result.accessToken);
    } catch (e) {
      throw AuthException(message: 'Refresh Token ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      if (_accessToken != null) {
        await _remoteDataSource.logout(_accessToken!);
      }
    } catch (e) {
      // Ignore error on logout
    } finally {
      _accessToken = null;
      _currentUser = null;

      // Clear stored tokens
      await _secureStorage.deleteAll();
    }
  }

  Future<UserEntity> getCurrentUser() async {
    // Try to restore from secure storage
    if (_accessToken == null) {
      await _restoreFromStorage();
    }

    if (_accessToken == null) {
      throw AuthException(message: 'ไม่มี Token');
    }

    try {
      final user = await _remoteDataSource.getCurrentUser(_accessToken!);
      _currentUser = user;
      return user;
    } catch (e) {
      throw AuthException(message: 'ดึงข้อมูลผู้ใช้ไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> _saveTokens(AuthResponseModel result) async {
    await _secureStorage.write(key: _keyAccessToken, value: result.accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: result.refreshToken);
    await _secureStorage.write(key: _keyUserId, value: result.user.userId);
    await _secureStorage.write(key: _keyUserEmail, value: result.user.email);
    await _secureStorage.write(key: _keyUserFullName, value: result.user.fullName);
    await _secureStorage.write(key: _keyUserRole, value: result.user.role);
  }

  Future<void> _restoreFromStorage() async {
    final accessToken = await _secureStorage.read(key: _keyAccessToken);
    if (accessToken != null) {
      _accessToken = accessToken;

      // Try to restore user info
      final userId = await _secureStorage.read(key: _keyUserId);
      final email = await _secureStorage.read(key: _keyUserEmail);
      final fullName = await _secureStorage.read(key: _keyUserFullName);
      final role = await _secureStorage.read(key: _keyUserRole);

      if (userId != null && email != null && fullName != null && role != null) {
        _currentUser = UserModel(
          userId: userId,
          email: email,
          fullName: fullName,
          username: email.split('@')[0],
          role: role,
          createdAt: DateTime.now(),
        );
      }
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}
