import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/machine/machine_bloc.dart';
import '../../blocs/machine/machine_event.dart';
import '../../blocs/repair/repair_bloc.dart';
import '../../blocs/repair/repair_event.dart';
import '../../blocs/pm_task/pm_task_bloc.dart';
import '../../blocs/pm_task/pm_task_event.dart';
import '../../../data/repositories/machine_repository.dart';
import '../../../data/datasources/remote/machine_remote_datasource.dart';
import '../../../data/repositories/repair_repository.dart';
import '../../../data/datasources/remote/repair_remote_datasource.dart';
import '../../../data/repositories/pm_task_repository.dart';
import '../../../data/datasources/remote/pm_task_remote_datasource.dart';
import '../../../services/api/api_client.dart';
import '../../widgets/dashboard/statistics_card.dart';
import '../../widgets/dashboard/repair_status_chart.dart';
import '../../widgets/dashboard/monthly_cost_chart.dart';
import '../../widgets/dashboard/pm_status_chart.dart';
import '../auth/login_page.dart';
import '../machine/machine_list_page.dart';
import '../repair/repair_list_page.dart';
import '../pm_task/pm_schedule_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(RefreshDashboard());
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index > 0) _navigateToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E40AF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.precision_manufacturing), label: 'Machines'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Repairs'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'PM'),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E40AF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.build, size: 50, color: Colors.white),
                const SizedBox(height: 8),
                const Text('AI Maintenance', style: TextStyle(color: Colors.white, fontSize: 18)),
                const Text('Assistant', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () { Navigator.pop(context); setState(() => _currentIndex = 0); },
          ),
          ListTile(
            leading: const Icon(Icons.precision_manufacturing),
            title: const Text('Machines'),
            onTap: () { Navigator.pop(context); _navigateToPage(1); },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Repairs'),
            onTap: () { Navigator.pop(context); _navigateToPage(2); },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('PM Schedule'),
            onTap: () { Navigator.pop(context); _navigateToPage(3); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return BlocProvider.value(
          value: context.read<MachineBloc>(),
          child: const MachineListPage(),
        );
      case 2:
        return BlocProvider.value(
          value: context.read<RepairBloc>(),
          child: const RepairListPage(),
        );
      case 3:
        return BlocProvider.value(
          value: context.read<PmTaskBloc>(),
          child: const PmSchedulePage(),
        );
      default:
        return _buildDashboardContent();
    }
  }

  void _navigateToPage(int index) {
    final apiClient = ApiClient(baseUrl: 'http://localhost:8000');
    
    Widget page;
    switch (index) {
      case 1:
        page = BlocProvider(
          create: (_) => MachineBloc(repository: MachineRepository(remoteDataSource: MachineRemoteDataSource(apiClient: apiClient)))..add(LoadMachines()),
          child: const MachineListPage(),
        );
        break;
      case 2:
        page = BlocProvider(
          create: (_) => RepairBloc(repository: RepairRepository(remoteDataSource: RepairRemoteDataSource(apiClient: apiClient)))..add(LoadRepairs()),
          child: const RepairListPage(),
        );
        break;
      case 3:
        page = BlocProvider(
          create: (_) => PmTaskBloc(repository: PmTaskRepository(remoteDataSource: PmTaskRemoteDataSource(apiClient: apiClient)))..add(LoadPmTasks()),
          child: const PmSchedulePage(),
        );
        break;
      default:
        return;
    }
    
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildDashboardContent() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () { context.read<DashboardBloc>().add(LoadDashboard()); },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is DashboardSummaryLoaded) {
          final summary = state.summary;
          return RefreshIndicator(
            onRefresh: () async { context.read<DashboardBloc>().add(RefreshDashboard()); },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatisticsCard(
                    totalMachines: summary.totalMachines,
                    activeMachines: summary.activeMachines,
                    totalRepairs: summary.totalRepairs,
                    pendingRepairs: summary.pendingRepairs,
                    completedRepairs: summary.completedRepairs,
                    totalPmTasks: summary.totalPmTasks,
                    overduePmTasks: summary.overduePmTasks,
                    totalCost: summary.totalRepairCost,
                  ),
                  const SizedBox(height: 16),
                  const RepairStatusChart(),
                  const SizedBox(height: 16),
                  const MonthlyCostChart(),
                  const SizedBox(height: 16),
                  const PMStatusChart(),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Top Issues', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          if (summary.topIssues.isEmpty)
                            const Text('No data available')
                          else
                            ...summary.topIssues.map((issue) {
                              return ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: const Icon(Icons.warning, color: Colors.red, size: 20)),
                                title: Text(issue.issue),
                                subtitle: Text('${issue.count} occurrences'),
                                trailing: Text('${issue.percentage.toStringAsFixed(1)}%'),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
