# AI Maintenance Assistant - Flutter Project Structure

---

## 1. Folder Structure

```
ai_maintenance_assistant/
├── android/                          # Android configuration
├── ios/                              # iOS configuration
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app.dart                      # App configuration
│   │
│   ├── core/                         # Core utilities
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── api_constants.dart
│   │   │   └── storage_keys.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── dark_theme.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── formatters.dart
│   │   │   ├── date_utils.dart
│   │   │   └── image_utils.dart
│   │   │
│   │   └── errors/
│   │       ├── exceptions.dart
│   │       └── failures.dart
│   │
│   ├── data/                         # Data layer
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── machine_model.dart
│   │   │   ├── repair_model.dart
│   │   │   ├── pm_task_model.dart
│   │   │   ├── spare_part_model.dart
│   │   │   ├── ai_analysis_model.dart
│   │   │   ├── report_model.dart
│   │   │   └── api_response_model.dart
│   │   │
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   ├── machine_remote_datasource.dart
│   │   │   │   ├── repair_remote_datasource.dart
│   │   │   │   ├── pm_remote_datasource.dart
│   │   │   │   ├── spare_part_remote_datasource.dart
│   │   │   │   ├── ai_remote_datasource.dart
│   │   │   │   └── report_remote_datasource.dart
│   │   │   │
│   │   │   └── local/
│   │   │       ├── auth_local_datasource.dart
│   │   │       └── cache_local_datasource.dart
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── machine_repository.dart
│   │       ├── repair_repository.dart
│   │       ├── pm_repository.dart
│   │       ├── spare_part_repository.dart
│   │       ├── ai_repository.dart
│   │       └── report_repository.dart
│   │
│   ├── domain/                       # Domain layer
│   │   ├── entities/
│   │   │   ├── user_entity.dart
│   │   │   ├── machine_entity.dart
│   │   │   ├── repair_entity.dart
│   │   │   ├── pm_task_entity.dart
│   │   │   ├── spare_part_entity.dart
│   │   │   ├── ai_analysis_entity.dart
│   │   │   └── report_entity.dart
│   │   │
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── login_usecase.dart
│   │       │   ├── register_usecase.dart
│   │       │   └── logout_usecase.dart
│   │       ├── machine/
│   │       │   ├── get_machines_usecase.dart
│   │       │   └── get_machine_detail_usecase.dart
│   │       ├── repair/
│   │       │   ├── get_repairs_usecase.dart
│   │       │   ├── create_repair_usecase.dart
│   │       │   └── update_repair_status_usecase.dart
│   │       └── ai/
│   │           └── analyze_breakdown_usecase.dart
│   │
│   ├── presentation/                 # Presentation layer
│   │   ├── blocs/                    # BLoC state management
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   ├── machine/
│   │   │   │   ├── machine_bloc.dart
│   │   │   │   ├── machine_event.dart
│   │   │   │   └── machine_state.dart
│   │   │   ├── repair/
│   │   │   │   ├── repair_bloc.dart
│   │   │   │   ├── repair_event.dart
│   │   │   │   └── repair_state.dart
│   │   │   ├── ai/
│   │   │   │   ├── ai_bloc.dart
│   │   │   │   ├── ai_event.dart
│   │   │   │   └── ai_state.dart
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_bloc.dart
│   │   │   │   ├── dashboard_event.dart
│   │   │   │   └── dashboard_state.dart
│   │   │   └── camera/
│   │   │       ├── camera_bloc.dart
│   │   │       ├── camera_event.dart
│   │   │       └── camera_state.dart
│   │   │
│   │   ├── pages/
│   │   │   ├── splash/
│   │   │   │   └── splash_page.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_page.dart
│   │   │   │   └── register_page.dart
│   │   │   ├── dashboard/
│   │   │   │   └── dashboard_page.dart
│   │   │   ├── camera/
│   │   │   │   └── camera_page.dart
│   │   │   ├── ai/
│   │   │   │   └── ai_result_page.dart
│   │   │   ├── machine/
│   │   │   │   ├── machine_list_page.dart
│   │   │   │   └── machine_detail_page.dart
│   │   │   ├── repair/
│   │   │   │   ├── repair_list_page.dart
│   │   │   │   ├── repair_detail_page.dart
│   │   │   │   └── create_repair_page.dart
│   │   │   ├── pm/
│   │   │   │   ├── pm_schedule_page.dart
│   │   │   │   └── pm_checklist_page.dart
│   │   │   ├── spare_part/
│   │   │   │   └── spare_part_page.dart
│   │   │   ├── report/
│   │   │   │   ├── report_list_page.dart
│   │   │   │   └── report_detail_page.dart
│   │   │   └── profile/
│   │   │       └── profile_page.dart
│   │   │
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── app_button.dart
│   │       │   ├── app_text_field.dart
│   │       │   ├── app_card.dart
│   │       │   ├── loading_widget.dart
│   │       │   ├── error_widget.dart
│   │       │   └── empty_widget.dart
│   │       ├── machine/
│   │       │   ├── machine_card.dart
│   │       │   └── machine_info_widget.dart
│   │       ├── repair/
│   │       │   ├── repair_card.dart
│   │       │   ├── status_badge.dart
│   │       │   └── priority_badge.dart
│   │       ├── ai/
│   │       │   ├── cause_card.dart
│   │       │   ├── confidence_bar.dart
│   │       │   └── solution_steps.dart
│   │       └── dashboard/
│   │           ├── summary_card.dart
│   │           ├── chart_widget.dart
│   │           └── recent_jobs_widget.dart
│   │
│   ├── services/                     # Services
│   │   ├── api/
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptor.dart
│   │   │   └── api_endpoints.dart
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   └── cache_service.dart
│   │   │
│   │   ├── camera/
│   │   │   └── camera_service.dart
│   │   │
│   │   ├── voice/
│   │   │   └── voice_service.dart
│   │   │
│   │   └── notification/
│   │       └── notification_service.dart
│   │
│   └── injection/                    # Dependency injection
│       └── injection_container.dart
│
├── test/                             # Test files
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── assets/                           # Assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml
└── README.md
```

---

## 2. State Management (BLoC)

### 2.1 Auth BLoC

```dart
// auth_event.dart
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  
  RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}


// auth_state.dart
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError({required this.message});
}


// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
      ),
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check if user is already logged in
    final result = await loginUseCase.checkAuth();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
```

### 2.2 Machine BLoC

```dart
// machine_event.dart
abstract class MachineEvent {}

class LoadMachines extends MachineEvent {}

class LoadMachineDetail extends MachineEvent {
  final String machineId;
  
  LoadMachineDetail({required this.machineId});
}

class SearchMachines extends MachineEvent {
  final String query;
  
  SearchMachines({required this.query});
}


// machine_state.dart
abstract class MachineState {}

class MachineInitial extends MachineState {}

class MachineLoading extends MachineState {}

class MachineLoaded extends MachineState {
  final List<Machine> machines;
  
  MachineLoaded({required this.machines});
}

class MachineDetailLoaded extends MachineState {
  final Machine machine;
  
  MachineDetailLoaded({required this.machine});
}

class MachineError extends MachineState {
  final String message;
  
  MachineError({required this.message});
}


// machine_bloc.dart
class MachineBloc extends Bloc<MachineEvent, MachineState> {
  final GetMachinesUseCase getMachinesUseCase;
  final GetMachineDetailUseCase getMachineDetailUseCase;

  MachineBloc({
    required this.getMachinesUseCase,
    required this.getMachineDetailUseCase,
  }) : super(MachineInitial()) {
    on<LoadMachines>(_onLoadMachines);
    on<LoadMachineDetail>(_onLoadMachineDetail);
    on<SearchMachines>(_onSearchMachines);
  }

  Future<void> _onLoadMachines(
    LoadMachines event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());
    
    final result = await getMachinesUseCase();
    
    result.fold(
      (failure) => emit(MachineError(message: failure.message)),
      (machines) => emit(MachineLoaded(machines: machines)),
    );
  }

  Future<void> _onLoadMachineDetail(
    LoadMachineDetail event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());
    
    final result = await getMachineDetailUseCase(
      MachineDetailParams(machineId: event.machineId),
    );
    
    result.fold(
      (failure) => emit(MachineError(message: failure.message)),
      (machine) => emit(MachineDetailLoaded(machine: machine)),
    );
  }

  Future<void> _onSearchMachines(
    SearchMachines event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());
    
    final result = await getMachinesUseCase(
      searchQuery: event.query,
    );
    
    result.fold(
      (failure) => emit(MachineError(message: failure.message)),
      (machines) => emit(MachineLoaded(machines: machines)),
    );
  }
}
```

### 2.3 AI BLoC

```dart
// ai_event.dart
abstract class AiEvent {}

class AnalyzeBreakdown extends AiEvent {
  final String machineId;
  final String? text;
  final List<File>? images;
  
  AnalyzeBreakdown({
    required this.machineId,
    this.text,
    this.images,
  });
}

class SubmitFeedback extends AiEvent {
  final String analysisId;
  final String feedback;
  final String? actualCause;
  
  SubmitFeedback({
    required this.analysisId,
    required this.feedback,
    this.actualCause,
  });
}

class ResetAiState extends AiEvent {}


// ai_state.dart
abstract class AiState {}

class AiInitial extends AiState {}

class AiAnalyzing extends AiState {
  final double progress;
  
  AiAnalyzing({this.progress = 0.0});
}

class AiResultLoaded extends AiState {
  final AIAnalysis analysis;
  
  AiResultLoaded({required this.analysis});
}

class AiError extends AiState {
  final String message;
  
  AiError({required this.message});
}

class AiFeedbackSubmitted extends AiState {}


// ai_bloc.dart
class AiBloc extends Bloc<AiEvent, AiState> {
  final AnalyzeBreakdownUseCase analyzeBreakdownUseCase;

  AiBloc({
    required this.analyzeBreakdownUseCase,
  }) : super(AiInitial()) {
    on<AnalyzeBreakdown>(_onAnalyzeBreakdown);
    on<SubmitFeedback>(_onSubmitFeedback);
    on<ResetAiState>(_onResetAiState);
  }

  Future<void> _onAnalyzeBreakdown(
    AnalyzeBreakdown event,
    Emitter<AiState> emit,
  ) async {
    emit(AiAnalyzing(progress: 0.0));
    
    // Upload images first if present
    List<String> imageUrls = [];
    if (event.images != null && event.images!.isNotEmpty) {
      emit(AiAnalyzing(progress: 0.2));
      // Upload images...
    }
    
    emit(AiAnalyzing(progress: 0.5));
    
    final result = await analyzeBreakdownUseCase(
      AnalyzeParams(
        machineId: event.machineId,
        text: event.text,
        imageUrls: imageUrls,
      ),
    );
    
    result.fold(
      (failure) => emit(AiError(message: failure.message)),
      (analysis) => emit(AiResultLoaded(analysis: analysis)),
    );
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<AiState> emit,
  ) async {
    // Submit feedback...
    emit(AiFeedbackSubmitted());
  }

  void _onResetAiState(
    ResetAiState event,
    Emitter<AiState> emit,
  ) {
    emit(AiInitial());
  }
}
```

---

## 3. API Service

### 3.1 API Client

```dart
// api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ApiClient({required SharedPreferences prefs}) : _prefs = prefs {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.aimaintenance.com/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(AuthInterceptor(prefs: _prefs));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return _dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return _dio.put(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  // Upload file
  Future<Response> uploadFile(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? data,
  }) async {
    final formData = FormData.fromMap({
      if (data != null) ...data,
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    
    return _dio.post(path, data: formData);
  }
}


// api_interceptor.dart
class AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  AuthInterceptor({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or logout
    }
    handler.next(err);
  }
}
```

### 3.2 API Endpoints

```dart
// api_endpoints.dart
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User
  static const String userMe = '/users/me';
  static const String users = '/users';

  // Machine
  static const String machines = '/machines';
  static String machineDetail(String id) => '/machines/$id';

  // Repair
  static const String repairs = '/repairs';
  static String repairDetail(String id) => '/repairs/$id';
  static String repairAssign(String id) => '/repairs/$id/assign';
  static String repairStatus(String id) => '/repairs/$id/status';
  static String repairComplete(String id) => '/repairs/$id/complete';

  // PM
  static const String pmTasks = '/pm-tasks';
  static String pmTaskDetail(String id) => '/pm-tasks/$id';
  static String pmTaskComplete(String id) => '/pm-tasks/$id/complete';

  // Spare Part
  static const String spareParts = '/spare-parts';
  static String sparePartDetail(String id) => '/spare-parts/$id';

  // AI
  static const String aiAnalyze = '/ai/analyze';
  static String aiAnalysis(String id) => '/ai/analysis/$id';
  static const String aiFeedback = '/ai/feedback';

  // Report
  static const String reports = '/reports';
  static String reportDetail(String id) => '/reports/$id';
  static String reportApprove(String id) => '/reports/$id/approve';
  static String reportReject(String id) => '/reports/$id/reject';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';
  static const String dashboardAnalytics = '/dashboard/analytics';

  // Upload
  static const String upload = '/upload';
}
```

### 3.3 Remote Data Source

```dart
// auth_remote_datasource.dart
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<RegisterResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      },
    );
    return RegisterResponse.fromJson(response.data);
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}


// ai_remote_datasource.dart
class AiRemoteDataSource {
  final ApiClient _apiClient;

  AiRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<AIAnalysisResponse> analyze({
    required String machineId,
    String? text,
    List<File>? images,
  }) async {
    final formData = FormData.fromMap({
      'machine_id': machineId,
      if (text != null) 'input_text': text,
      if (images != null)
        'images': await Future.wait(
          images.map((img) => MultipartFile.fromFile(
            img.path,
            filename: img.path.split('/').last,
          )),
        ),
    });

    final response = await _apiClient.post(
      ApiEndpoints.aiAnalyze,
      data: formData,
    );
    
    return AIAnalysisResponse.fromJson(response.data);
  }
}
```

---

## 4. Screen Navigation

### 4.1 Route Configuration

```dart
// app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main Shell (with bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // Camera
          GoRoute(
            path: '/camera',
            builder: (context, state) => const CameraPage(),
          ),

          // History
          GoRoute(
            path: '/history',
            builder: (context, state) => const RepairListPage(),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // AI Result
      GoRoute(
        path: '/ai-result',
        builder: (context, state) {
          final analysisId = state.queryParameters['analysisId'];
          return AiResultPage(analysisId: analysisId);
        },
      ),

      // Machine Detail
      GoRoute(
        path: '/machine/:id',
        builder: (context, state) {
          final machineId = state.pathParameters['id']!;
          return MachineDetailPage(machineId: machineId);
        },
      ),

      // Repair Detail
      GoRoute(
        path: '/repair/:id',
        builder: (context, state) {
          final repairId = state.pathParameters['id']!;
          return RepairDetailPage(repairId: repairId);
        },
      ),

      // Create Repair
      GoRoute(
        path: '/repair/create',
        builder: (context, state) {
          final machineId = state.queryParameters['machineId'];
          return CreateRepairPage(machineId: machineId);
        },
      ),

      // PM Schedule
      GoRoute(
        path: '/pm-schedule',
        builder: (context, state) => const PmSchedulePage(),
      ),

      // PM Checklist
      GoRoute(
        path: '/pm-checklist/:id',
        builder: (context, state) {
          final pmId = state.pathParameters['id']!;
          return PmChecklistPage(pmId: pmId);
        },
      ),

      // Spare Parts
      GoRoute(
        path: '/spare-parts',
        builder: (context, state) => const SparePartPage(),
      ),

      // Reports
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportListPage(),
      ),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) {
          final reportId = state.pathParameters['id']!;
          return ReportDetailPage(reportId: reportId);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = authBloc.state is AuthAuthenticated;
      final isLoginRoute = state.location == '/login';
      final isRegisterRoute = state.location == '/register';
      final isSplash = state.location == '/';

      // If on splash, allow
      if (isSplash) return null;

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        return '/login';
      }

      // If logged in and on auth pages, redirect to dashboard
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        return '/dashboard';
      }

      return null;
    },
  );
}
```

### 4.2 Main Shell (Bottom Navigation)

```dart
// main_shell.dart
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).location;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/camera')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/camera');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
```

---

## 5. Dependency Injection

```dart
// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Core
  sl.registerLazySingleton(() => ApiClient(prefs: sl()));

  // Data Sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(() => MachineRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(() => RepairRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(() => AiRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(() => AuthLocalDataSource(prefs: sl()));

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ));
  sl.registerLazySingleton(() => MachineRepository(
    remoteDataSource: sl(),
  ));
  sl.registerLazySingleton(() => RepairRepository(
    remoteDataSource: sl(),
  ));
  sl.registerLazySingleton(() => AiRepository(
    remoteDataSource: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMachinesUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetMachineDetailUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetRepairsUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateRepairUseCase(repository: sl()));
  sl.registerLazySingleton(() => AnalyzeBreakdownUseCase(repository: sl()));

  // BLoCs
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
    logoutUseCase: sl(),
  ));
  sl.registerFactory(() => MachineBloc(
    getMachinesUseCase: sl(),
    getMachineDetailUseCase: sl(),
  ));
  sl.registerFactory(() => RepairBloc(
    getRepairsUseCase: sl(),
    createRepairUseCase: sl(),
  ));
  sl.registerFactory(() => AiBloc(
    analyzeBreakdownUseCase: sl(),
  ));
  sl.registerFactory(() => DashboardBloc());
}
```

---

## 6. Main Entry Point

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => di.sl<MachineBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<RepairBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<AiBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<DashboardBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'AI Maintenance Assistant',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter(
          authBloc: di.sl<AuthBloc>(),
        ).router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

---

## 7. Screen Examples

### 7.1 Login Page

```dart
// login_page.dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 100,
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'AI Maintenance Assistant',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    
                    // Email Field
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 24),
                    
                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          text: 'Login',
                          isLoading: state is AuthLoading,
                          onPressed: _onLogin,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Register Link
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text("Don't have account? Register"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 7.2 Camera Page

```dart
// camera_page.dart
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  final _textController = TextEditingController();
  final List<File> _images = [];
  String? _selectedMachineId;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Machine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Machine Selector
            AppTextField(
              controller: TextEditingController(text: _selectedMachineId),
              label: 'Machine',
              prefixIcon: Icons.precision_manufacturing,
              readOnly: true,
              onTap: _showMachinePicker,
            ),
            const SizedBox(height: 16),
            
            // Camera Preview
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_cameraController!),
              ),
            const SizedBox(height: 16),
            
            // Capture Button
            AppButton(
              text: 'Capture Photo',
              icon: Icons.camera_alt,
              onPressed: _capturePhoto,
            ),
            const SizedBox(height: 16),
            
            // Image Preview
            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            
            // Description Field
            AppTextField(
              controller: _textController,
              label: 'Describe the issue',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Analyze Button
            BlocBuilder<AiBloc, AiState>(
              builder: (context, state) {
                return AppButton(
                  text: 'Analyze with AI',
                  icon: Icons.auto_awesome,
                  isLoading: state is AiAnalyzing,
                  onPressed: _analyze,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    final photo = await _cameraController!.takePicture();
    setState(() {
      _images.add(File(photo.path));
    });
  }

  void _showMachinePicker() {
    // Show machine picker modal
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BlocBuilder<MachineBloc, MachineState>(
          builder: (context, state) {
            if (state is MachineLoaded) {
              return ListView.builder(
                itemCount: state.machines.length,
                itemBuilder: (context, index) {
                  final machine = state.machines[index];
                  return ListTile(
                    title: Text(machine.name),
                    subtitle: Text(machine.serialNumber),
                    onTap: () {
                      setState(() {
                        _selectedMachineId = machine.machineId;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  void _analyze() {
    if (_selectedMachineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a machine')),
      );
      return;
    }
    
    context.read<AiBloc>().add(AnalyzeBreakdown(
      machineId: _selectedMachineId!,
      text: _textController.text,
      images: _images,
    ));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textController.dispose();
    super.dispose();
  }
}
```
