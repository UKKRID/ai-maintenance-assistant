import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/spare_part/spare_part_bloc.dart';
import '../../blocs/spare_part/spare_part_event.dart';
import '../../blocs/spare_part/spare_part_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api/api_client.dart';
import '../../../services/image/image_upload_service.dart';

class AddEditSparePartPage extends StatefulWidget {
  final String? partId;

  const AddEditSparePartPage({super.key, this.partId});

  @override
  State<AddEditSparePartPage> createState() => _AddEditSparePartPageState();
}

class _AddEditSparePartPageState extends State<AddEditSparePartPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _stockQtyController = TextEditingController();
  final _minStockController = TextEditingController();

  String _selectedCategory = 'bearing';
  String _selectedUnit = 'piece';
  XFile? _selectedImage;
  String? _uploadedImageUrl;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  bool get isEditing => widget.partId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      context.read<SparePartBloc>().add(LoadSparePartDetail(partId: widget.partId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'แก้ไขอะไหล่' : 'เพิ่มอะไหล่',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SparePartBloc, SparePartState>(
        listener: (context, state) {
          if (state is SparePartOperationSuccess) {
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
          } else if (state is SparePartError) {
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
          } else if (state is SparePartDetailLoaded && isEditing) {
            final part = state.sparePart;
            _nameController.text = part.name;
            _partNumberController.text = part.partNumber;
            _descriptionController.text = part.description ?? '';
            _unitPriceController.text = part.unitPrice.toString();
            _stockQtyController.text = part.stockQty.toString();
            _minStockController.text = part.minStock.toString();
            _selectedCategory = part.category ?? 'bearing';
            _selectedUnit = part.unit;
            if (part.imageUrl != null && part.imageUrl!.isNotEmpty) {
              _uploadedImageUrl = part.imageUrl;
            }
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
                  label: 'ชื่ออะไหล่ *',
                  icon: Icons.inventory,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกชื่ออะไหล่';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Part Number
                _buildTextField(
                  controller: _partNumberController,
                  label: 'หมายเลขอะไหล่ *',
                  icon: Icons.qr_code,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกหมายเลขอะไหล่';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                _buildCategoryDropdown(),
                const SizedBox(height: 16),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'รายละเอียด',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Unit Price
                _buildTextField(
                  controller: _unitPriceController,
                  label: 'ราคาต่อหน่วย *',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'กรุณากรอกราคา';
                    if (double.tryParse(value) == null) return 'กรุณากรอกตัวเลข';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Stock Qty & Min Stock
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _stockQtyController,
                        label: 'จำนวนคงเหลือ',
                        icon: Icons.inventory_2,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _minStockController,
                        label: 'ขั้นต่ำ',
                        icon: Icons.warning_amber,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unit
                _buildUnitDropdown(),
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
              'รูปอะไหล่',
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
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: _buildImageContent(),
              ),
            ),
            if (_selectedImage != null || _uploadedImageUrl != null) ...[
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

    if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          'http://localhost:8000$_uploadedImageUrl',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 48, color: AppColors.textHint),
        const SizedBox(height: 8),
        Text('แตะเพื่อเลือกรูป', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text('รองรับ JPEG, PNG, WebP', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'หมวดหมู่',
        prefixIcon: const Icon(Icons.category),
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
        DropdownMenuItem(value: 'bearing', child: Text('Bearing')),
        DropdownMenuItem(value: 'belt', child: Text('Belt')),
        DropdownMenuItem(value: 'filter', child: Text('Filter')),
        DropdownMenuItem(value: 'oil', child: Text('Oil')),
        DropdownMenuItem(value: 'seal', child: Text('Seal')),
        DropdownMenuItem(value: 'gasket', child: Text('Gasket')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => _selectedCategory = value!),
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      decoration: InputDecoration(
        labelText: 'หน่วย',
        prefixIcon: const Icon(Icons.straighten),
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
        DropdownMenuItem(value: 'piece', child: Text('ชิ้น')),
        DropdownMenuItem(value: 'kg', child: Text('กิโลกรัม')),
        DropdownMenuItem(value: 'liter', child: Text('ลิตร')),
        DropdownMenuItem(value: 'meter', child: Text('เมตร')),
        DropdownMenuItem(value: 'set', child: Text('ชุด')),
      ],
      onChanged: (value) => setState(() => _selectedUnit = value!),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SparePartBloc, SparePartState>(
      builder: (context, state) {
        final isLoading = state is SparePartLoading || _isUploading;
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มอะไหล่',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
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
          folder: 'spare_parts',
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

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        context.read<SparePartBloc>().add(UpdateSparePart(
          partId: widget.partId!,
          name: _nameController.text.trim(),
          partNumber: _partNumberController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
          stockQty: int.tryParse(_stockQtyController.text) ?? 0,
          minStock: int.tryParse(_minStockController.text) ?? 0,
          unit: _selectedUnit,
          imageUrl: _uploadedImageUrl,
        ));
      } else {
        context.read<SparePartBloc>().add(CreateSparePart(
          name: _nameController.text.trim(),
          partNumber: _partNumberController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
          stockQty: int.tryParse(_stockQtyController.text) ?? 0,
          minStock: int.tryParse(_minStockController.text) ?? 0,
          unit: _selectedUnit,
          imageUrl: _uploadedImageUrl,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _partNumberController.dispose();
    _descriptionController.dispose();
    _unitPriceController.dispose();
    _stockQtyController.dispose();
    _minStockController.dispose();
    super.dispose();
  }
}
