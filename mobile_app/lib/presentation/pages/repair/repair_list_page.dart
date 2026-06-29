import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/repair/repair_bloc.dart';
import '../../blocs/repair/repair_event.dart';
import '../../blocs/repair/repair_state.dart';
import 'repair_detail_page.dart';
import 'create_repair_page.dart';

class RepairListPage extends StatefulWidget {
  const RepairListPage({super.key});

  @override
  State<RepairListPage> createState() => _RepairListPageState();
}

class _RepairListPageState extends State<RepairListPage> {
  final _searchController = TextEditingController();
  String? _selectedStatus;
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    try {
      final state = context.read<RepairBloc>().state;
      if (state is RepairInitial) {
        context.read<RepairBloc>().add(LoadRepairs());
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairs'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateRepairPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search repairs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<RepairBloc>().add(LoadRepairs());
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                context.read<RepairBloc>().add(SearchRepairs(query: value));
              },
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter('All', null),
                  const SizedBox(width: 8),
                  _buildStatusFilter('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildStatusFilter('In Progress', 'in_progress'),
                  const SizedBox(width: 8),
                  _buildStatusFilter('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildStatusFilter('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Repair List
          Expanded(
            child: BlocBuilder<RepairBloc, RepairState>(
              builder: (context, state) {
                if (state is RepairLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RepairError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<RepairBloc>().add(LoadRepairs()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is RepairListLoaded) {
                  if (state.repairs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.build_circle_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No repairs found'),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Summary
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.grey[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${state.total} repairs',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.repairs.length} showing',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<RepairBloc>().add(LoadRepairs());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.repairs.length,
                            itemBuilder: (context, index) {
                              final repair = state.repairs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getPriorityColor(repair.priority),
                                    child: const Icon(Icons.build, color: Colors.white),
                                  ),
                                  title: Text(
                                    repair.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${repair.machineName ?? repair.machineId}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Row(
                                        children: [
                                          _buildStatusChip(repair.status),
                                          const SizedBox(width: 8),
                                          _buildPriorityChip(repair.priority),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider.value(
                                          value: context.read<RepairBloc>(),
                                          child: RepairDetailPage(
                                            repairId: repair.repairId,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildStatusFilter(String label, String? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = status);
        context.read<RepairBloc>().add(LoadRepairs(status: status));
      },
      selectedColor: const Color(0xFF1E40AF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1E40AF),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Repairs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildPriorityFilterChip('All', null),
                _buildPriorityFilterChip('Low', 'low'),
                _buildPriorityFilterChip('Medium', 'medium'),
                _buildPriorityFilterChip('High', 'high'),
                _buildPriorityFilterChip('Critical', 'critical'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
                _selectedPriority = null;
              });
              context.read<RepairBloc>().add(LoadRepairs());
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFilterChip(String label, String? priority) {
    final isSelected = _selectedPriority == priority;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedPriority = priority);
        // Apply priority filter
        context.read<RepairBloc>().add(LoadRepairs(
          status: _selectedStatus,
          priority: priority,
        ));
        Navigator.pop(context);
      },
      selectedColor: _getPriorityColor(priority ?? 'medium').withOpacity(0.2),
      checkmarkColor: _getPriorityColor(priority ?? 'medium'),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
