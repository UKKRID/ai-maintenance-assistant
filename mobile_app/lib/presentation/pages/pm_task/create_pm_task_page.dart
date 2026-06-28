import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/pm_task/pm_task_bloc.dart';
import '../../blocs/pm_task/pm_task_event.dart';
import '../../blocs/pm_task/pm_task_state.dart';

class CreatePmTaskPage extends StatefulWidget {
  const CreatePmTaskPage({super.key});

  @override
  State<CreatePmTaskPage> createState() => _CreatePmTaskPageState();
}

class _CreatePmTaskPageState extends State<CreatePmTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _checklistController = TextEditingController();

  String _selectedMachineId = 'machine-001';
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  final List<Map<String, dynamic>> _checklist = [];

  final List<Map<String, String>> _machines = [
    {'id': 'machine-001', 'name': 'Motor Pump A'},
    {'id': 'machine-002', 'name': 'Conveyor Belt B'},
    {'id': 'machine-003', 'name': 'CNC Machine C'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PM Task'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<PmTaskBloc, PmTaskState>(
        listener: (context, state) {
          if (state is PmTaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is PmTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMachineId,
                  decoration: InputDecoration(
                    labelText: 'Machine *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _machines.map((m) => DropdownMenuItem(value: m['id'], child: Text(m['name']!))).toList(),
                  onChanged: (value) => setState(() => _selectedMachineId = value!),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                ListTile(
                  title: const Text('Scheduled Date *'),
                  subtitle: Text('${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[400]!)),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ..._checklist.asMap().entries.map((entry) {
                          return ListTile(
                            leading: Text('${entry.key + 1}.'),
                            title: Text(entry.value['item_name']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _checklist.removeAt(entry.key)),
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _checklistController,
                                decoration: const InputDecoration(hintText: 'Add checklist item'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFF1E40AF)),
                              onPressed: _addChecklistItem,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                BlocBuilder<PmTaskBloc, PmTaskState>(
                  builder: (context, state) {
                    final isLoading = state is PmTaskLoading;
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create PM Task', style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addChecklistItem() {
    if (_checklistController.text.isNotEmpty) {
      setState(() {
        _checklist.add({
          'item_name': _checklistController.text,
          'is_required': true,
          'sort_order': _checklist.length + 1,
        });
        _checklistController.clear();
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<PmTaskBloc>().add(CreatePmTask(
        machineId: _selectedMachineId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text.trim() : null,
        scheduledDate: _scheduledDate.toIso8601String().split('T')[0],
        checklist: _checklist.isNotEmpty ? _checklist : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _checklistController.dispose();
    super.dispose();
  }
}
