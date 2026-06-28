import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pm_task/pm_task_bloc.dart';
import '../../blocs/pm_task/pm_task_event.dart';
import '../../blocs/pm_task/pm_task_state.dart';
import 'pm_detail_page.dart';
import 'create_pm_task_page.dart';

class PmSchedulePage extends StatefulWidget {
  const PmSchedulePage({super.key});

  @override
  State<PmSchedulePage> createState() => _PmSchedulePageState();
}

class _PmSchedulePageState extends State<PmSchedulePage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<PmTaskBloc>().add(LoadPmTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PM Schedule'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePmTaskPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search PM tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                context.read<PmTaskBloc>().add(SearchPmTasks(query: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Scheduled', 'scheduled'),
                  const SizedBox(width: 8),
                  _buildFilterChip('In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Overdue', 'overdue'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<PmTaskBloc, PmTaskState>(
              builder: (context, state) {
                if (state is PmTaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PmTaskError) {
                  return Center(child: Text(state.message));
                }
                if (state is PmTaskListLoaded) {
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text('No PM tasks found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PmTaskBloc>().add(LoadPmTasks());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(task.status),
                              child: Icon(Icons.calendar_today, color: Colors.white),
                            ),
                            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.machineName ?? task.machineId),
                                Row(
                                  children: [
                                    _buildStatusChip(task.status),
                                    const SizedBox(width: 8),
                                    if (task.checklistTotal > 0)
                                      Text('${task.checklistCompleted}/${task.checklistTotal} items'),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PmDetailPage(pmId: task.pmId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = status);
        context.read<PmTaskBloc>().add(LoadPmTasks(status: status));
      },
      selectedColor: const Color(0xFF1E40AF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1E40AF),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'overdue': return Colors.red;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
