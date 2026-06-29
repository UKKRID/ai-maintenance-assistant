import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/machine/machine_bloc.dart';
import '../../blocs/machine/machine_event.dart';
import '../../blocs/machine/machine_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api/api_client.dart';
import '../../../services/image/image_upload_service.dart';

class AddMachinePage extends StatefulWidget {
  const AddMachinePage({super.key});

  @override
  State<AddMachinePage> createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _locationController = TextEditingController();
  final _departmentController = TextEditingController();
  DateTime _installDate = DateTime.now();
  String _status = 'active';
  XFile? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('เพิ่มเครื่องจักร', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<MachineBloc, MachineState>(
        listener: (context, state) {
          if (state is MachineOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            Navigator.pop(context);
          } else if (state is MachineError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                // Image Picker
                _buildImagePicker(),
                const SizedBox(height: 24),

                // Name
                _buildTextField(
                  controller: _nameController,
                  label: 'ชื่อเครื่องจักร *',
                  icon: Icons.precision_manufacturing,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกชื่อเครื่องจักร';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Model
                _buildTextField(
                  controller: _modelController,
                  label: 'รุ่น *',
                  icon: Icons.model_training,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกรุ่น';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Serial Number
                _buildTextField(
                  controller: _serialController,
                  label: 'หมายเลขเครื่อง *',
                  icon: Icons.qr_code,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกหมายเลขเครื่อง';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Location
                _buildTextField(
                  controller: _locationController,
                  label: 'สถานที่ตั้ง *',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกสถานที่ตั้ง';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department
                _buildTextField(
                  controller: _departmentController,
                  label: 'แผนก',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),

                // Install Date
                _buildDatePicker(),
                const SizedBox(height: 16),

                // Status
                _buildStatusDropdown(),
                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'รูปเครื่องจักร',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                ),
                child: _buildImageContent(),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('เปลี่ยนรูป'),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _uploadedImageUrl = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                    label: const Text('ลบรูป', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('กำลังอัพโหลด...'),
        ],
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: kIsWeb
            ? Image.network(
                _selectedImage!.path,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text(
          'แตะเพื่อเลือกรูป',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          'รองรับ JPEG, PNG, WebP',
          style: TextStyle(color: AppColors.textHint, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: const Text('วันที่ติดตั้ง *'),
        subtitle: Text(
          '${_installDate.day}/${_installDate.month}/${_installDate.year}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: InputDecoration(
        labelText: 'สถานะ',
        prefixIcon: const Icon(Icons.info_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      items: const [
        DropdownMenuItem(value: 'active', child: Text('ใช้งาน')),
        DropdownMenuItem(value: 'inactive', child: Text('ไม่ใช้งาน')),
      ],
      onChanged: (value) => setState(() => _status = value!),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<MachineBloc, MachineState>(
      builder: (context, state) {
        final isLoading = state is MachineLoading || _isUploading;
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : _onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, size: 20),
                      SizedBox(width: 8),
                      Text('บันทึก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isUploading = true;
      });

      try {
        final apiClient = ApiClient(
          baseUrl: 'http://localhost:8000',
          token: ApiClient.globalToken,
        );
        final uploadService = ImageUploadService(apiClient: apiClient);
        final result = await uploadService.uploadImage(
          File(image.path),
          folder: 'machines',
        );

        setState(() {
          _uploadedImageUrl = result['url'];
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อัพโหลดรูปไม่สำเร็จ: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
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
      setState(() => _installDate = picked);
    }
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<MachineBloc>().add(CreateMachine(
        name: _nameController.text.trim(),
        model: _modelController.text.trim(),
        serialNumber: _serialController.text.trim(),
        location: _locationController.text.trim(),
        department: _departmentController.text.isNotEmpty
            ? _departmentController.text.trim()
            : null,
        installDate: _installDate.toIso8601String().split('T')[0],
        status: _status,
        imageUrl: _uploadedImageUrl,
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
