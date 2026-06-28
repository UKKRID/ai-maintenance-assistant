import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pm_task/pm_task_bloc.dart';
import '../../blocs/pm_task/pm_task_event.dart';
import '../../blocs/pm_task/pm_task_state.dart';

class PmDetailPage extends StatefulWidget {
  final String pmId;

  const PmDetailPage({super.key, required this.pmId});

  @override
  State<PmDetailPage> createState() => _PmDetailPageState();
}

class _PmDetailPageState extends State<PmDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PmTaskBloc>().add(LoadPmTaskDetail(pmId: widget.pmId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PM Detail'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'start', child: Text('Start')),
              const PopupMenuItem(value: 'complete', child: Text('Complete')),
              const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<PmTaskBloc, PmTaskState>(
        builder: (context, state) {
          if (state is PmTaskLoading) return const Center(child: CircularProgressIndicator());
          if (state is PmTaskError) return Center(child: Text(state.message));

          if (state is PmTaskDetailLoaded) {
            final task = state.task;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getStatusColor(task.status),
                                child: const Icon(Icons.calendar_today, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(task.machineName ?? task.machineId, style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatusChip(task.status),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          _buildInfoRow('Scheduled Date', task.scheduledDate),
                          if (task.completedDate != null)
                            _buildInfoRow('Completed Date', task.completedDate!),
                          _buildInfoRow('Assigned To', task.assignedName ?? 'Unassigned'),
                          if (task.description != null)
                            _buildInfoRow('Description', task.description!),
                          if (task.notes != null)
                            _buildInfoRow('Notes', task.notes!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (task.checklist.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('${task.checklistCompleted}/${task.checklistTotal} (${task.checklistPercentage}%)'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: task.checklistPercentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                task.checklistPercentage == 100 ? Colors.green : Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...task.checklist.map((item) => CheckboxListTile(
                              title: Text(item.itemName),
                              subtitle: item.isRequired ? const Text('Required', style: TextStyle(fontSize: 12)) : null,
                              value: item.isCompleted,
                              onChanged: task.status == 'completed' ? null : (value) {
                                context.read<PmTaskBloc>().add(UpdateChecklistItem(
                                  pmId: widget.pmId,
                                  checklistId: item.checklistId,
                                  itemId: item.checklistId,
                                  isCompleted: value ?? false,
                                ));
                              },
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (task.status != 'completed' && task.status != 'cancelled')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCompleteDialog(),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Complete PM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return Colors.blue;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'overdue': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'start':
        context.read<PmTaskBloc>().add(UpdatePmTask(pmId: widget.pmId, status: 'in_progress'));
        break;
      case 'complete':
        _showCompleteDialog();
        break;
      case 'cancel':
        context.read<PmTaskBloc>().add(UpdatePmTask(pmId: widget.pmId, status: 'cancelled'));
        break;
    }
  }

  void _showCompleteDialog() {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete PM'),
        content: TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<PmTaskBloc>().add(CompletePmTask(
                pmId: widget.pmId,
                notes: notesController.text.isNotEmpty ? notesController.text : null,
              ));
              Navigator.pop(context);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
