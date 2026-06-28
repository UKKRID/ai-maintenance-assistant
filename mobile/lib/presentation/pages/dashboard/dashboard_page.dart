import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../blocs/dashboard/dashboard_event.dart';
import '../../blocs/dashboard/dashboard_state.dart';
import '../../widgets/dashboard/statistics_card.dart';
import '../../widgets/dashboard/repair_status_chart.dart';
import '../../widgets/dashboard/monthly_cost_chart.dart';
import '../../widgets/dashboard/pm_status_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
      body: BlocBuilder<DashboardBloc, DashboardState>(
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
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardSummaryLoaded) {
            final summary = state.summary;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboard());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Card
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

                    // Repair Status Chart
                    const RepairStatusChart(),
                    const SizedBox(height: 16),

                    // Monthly Cost Chart
                    const MonthlyCostChart(),
                    const SizedBox(height: 16),

                    // PM Status Chart
                    const PMStatusChart(),
                    const SizedBox(height: 16),

                    // Top Issues
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Issues',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (summary.topIssues.isEmpty)
                              const Text('No data available')
                            else
                              ...summary.topIssues.map((issue) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    child: const Icon(Icons.warning, color: Colors.red, size: 20),
                                  ),
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
      ),
    );
  }
}
