import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/machine/machine_bloc.dart';
import 'presentation/blocs/repair/repair_bloc.dart';
import 'presentation/blocs/pm_task/pm_task_bloc.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/blocs/ai/ai_bloc.dart';
import 'presentation/blocs/spare_part/spare_part_bloc.dart';
import 'presentation/pages/auth/login_page.dart';
import 'data/repositories/auth_repository.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/repositories/machine_repository.dart';
import 'data/datasources/remote/machine_remote_datasource.dart';
import 'data/repositories/repair_repository.dart';
import 'data/datasources/remote/repair_remote_datasource.dart';
import 'data/repositories/pm_task_repository.dart';
import 'data/datasources/remote/pm_task_remote_datasource.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/datasources/remote/dashboard_remote_datasource.dart';
import 'data/repositories/ai_repository.dart';
import 'data/datasources/remote/ai_remote_datasource.dart';
import 'data/repositories/spare_part_repository.dart';
import 'data/datasources/remote/spare_part_remote_datasource.dart';
import 'services/api/api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient(baseUrl: 'http://localhost:8000');

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(
            remoteDataSource: AuthRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => MachineRepository(
            remoteDataSource: MachineRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => RepairRepository(
            remoteDataSource: RepairRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => PmTaskRepository(
            remoteDataSource: PmTaskRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => DashboardRepository(
            remoteDataSource: DashboardRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => AiRepository(
            remoteDataSource: AiRemoteDataSource(apiClient: apiClient),
          ),
        ),
        RepositoryProvider(
          create: (_) => SparePartRepository(
            remoteDataSource: SparePartRemoteDataSource(apiClient: apiClient),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              repository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => MachineBloc(
              repository: context.read<MachineRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RepairBloc(
              repository: context.read<RepairRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PmTaskBloc(
              repository: context.read<PmTaskRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              repository: context.read<DashboardRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AiBloc(
              repository: context.read<AiRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => SparePartBloc(
              repository: context.read<SparePartRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'AI Maintenance Assistant',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E40AF)),
            useMaterial3: true,
          ),
          home: const LoginPage(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
