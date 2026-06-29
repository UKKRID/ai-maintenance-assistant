import 'dart:async';
import 'package:web/web.dart' as web;
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../services/api/api_client.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

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

      // Set global token for all ApiClients
      ApiClient.setToken(result.accessToken);

      // Save to localStorage (for web)
      web.window.localStorage.setItem('access_token', result.accessToken);
      web.window.localStorage.setItem('refresh_token', result.refreshToken);
      web.window.localStorage.setItem('user_id', result.user.userId);
      web.window.localStorage.setItem('user_email', result.user.email);
      web.window.localStorage.setItem('user_fullname', result.user.fullName);
      web.window.localStorage.setItem('user_role', result.user.role);

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

      // Save to localStorage (for web)
      web.window.localStorage.setItem('access_token', result.accessToken);
      web.window.localStorage.setItem('refresh_token', result.refreshToken);
      web.window.localStorage.setItem('user_id', result.user.userId);
      web.window.localStorage.setItem('user_email', result.user.email);
      web.window.localStorage.setItem('user_fullname', result.user.fullName);
      web.window.localStorage.setItem('user_role', result.user.role);

      return result;
    } catch (e) {
      throw AuthException(message: 'สมัครสมาชิกไม่สำเร็จ: ${e.toString()}');
    }
  }

  Future<void> refreshToken() async {
    final storedRefreshToken = web.window.localStorage.getItem('refresh_token');
    if (storedRefreshToken == null) {
      throw AuthException(message: 'ไม่มี Refresh Token');
    }

    try {
      final result = await _remoteDataSource.refreshToken(storedRefreshToken);
      _accessToken = result.accessToken;
      web.window.localStorage.setItem('access_token', result.accessToken);
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
      
      // Clear global token
      ApiClient.setToken(null);
      
      web.window.localStorage.removeItem('access_token');
      web.window.localStorage.removeItem('refresh_token');
      web.window.localStorage.removeItem('user_id');
      web.window.localStorage.removeItem('user_email');
      web.window.localStorage.removeItem('user_fullname');
      web.window.localStorage.removeItem('user_role');
    }
  }

  Future<UserEntity> getCurrentUser() async {
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

  Future<void> _restoreFromStorage() async {
    final accessToken = web.window.localStorage.getItem('access_token');
    if (accessToken != null) {
      _accessToken = accessToken;
      
      // Set global token
      ApiClient.setToken(accessToken);

      final userId = web.window.localStorage.getItem('user_id');
      final email = web.window.localStorage.getItem('user_email');
      final fullName = web.window.localStorage.getItem('user_fullname');
      final role = web.window.localStorage.getItem('user_role');

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
