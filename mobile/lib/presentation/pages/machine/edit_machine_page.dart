import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/machine/machine_bloc.dart';
import '../../blocs/machine/machine_event.dart';
import '../../blocs/machine/machine_state.dart';

class EditMachinePage extends StatefulWidget {
  final String machineId;

  const EditMachinePage({super.key, required this.machineId});

  @override
  State<EditMachinePage> createState() => _EditMachinePageState();
}

class _EditMachinePageState extends State<EditMachinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  DateTime _installDate = DateTime.now();
  String _status = 'active';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMachine();
  }

  void _loadMachine() {
    context.read<MachineBloc>().add(LoadMachineDetail(machineId: widget.machineId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Machine'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<MachineBloc, MachineState>(
        listener: (context, state) {
          if (state is MachineOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is MachineError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<MachineBloc, MachineState>(
          builder: (context, state) {
            if (state is MachineLoading && _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MachineDetailLoaded && _isLoading) {
              _initializeFields(state);
              _isLoading = false;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Machine Name *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter machine name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Model
                    TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Model *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter model';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Serial Number
                    TextFormField(
                      controller: _serialController,
                      decoration: InputDecoration(
                        labelText: 'Serial Number *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter serial number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Department
                    TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Install Date
                    ListTile(
                      title: const Text('Install Date *'),
                      subtitle: Text(
                        '${_installDate.day}/${_installDate.month}/${_installDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),

                    // Status
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        DropdownMenuItem(value: 'under_repair', child: Text('Under Repair')),
                        DropdownMenuItem(value: 'disposed', child: Text('Disposed')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    BlocBuilder<MachineBloc, MachineState>(
                      builder: (context, state) {
                        final isLoading = state is MachineLoading;
                        return SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E40AF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Save Changes', style: TextStyle(fontSize: 16)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _initializeFields(dynamic state) {
    if (state is MachineDetailLoaded) {
      final machine = state.machine;
      _nameController.text = machine.name;
      _modelController.text = machine.model;
      _serialController.text = machine.serialNumber;
      _locationController.text = machine.location;
      _departmentController.text = machine.department ?? '';
      _installDate = DateTime.parse(machine.installDate);
      _status = machine.status;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _installDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _installDate = picked;
      });
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<MachineBloc>().add(UpdateMachine(
        machineId: widget.machineId,
        name: _nameController.text.trim(),
        model: _modelController.text.trim(),
        serialNumber: _serialController.text.trim(),
        location: _locationController.text.trim(),
        department: _departmentController.text.isNotEmpty
            ? _departmentController.text.trim()
            : null,
        installDate: _installDate.toIso8601String().split('T')[0],
        status: _status,
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _serialController.dispose();
    _locationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}
