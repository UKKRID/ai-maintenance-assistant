import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/spare_part/spare_part_bloc.dart';
import '../../blocs/spare_part/spare_part_event.dart';
import '../../blocs/spare_part/spare_part_state.dart';

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
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'bearing';
  String _selectedUnit = 'piece';

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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Spare Part' : 'Add Spare Part'),
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
      ),
      body: BlocListener<SparePartBloc, SparePartState>(
        listener: (context, state) {
          if (state is SparePartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is SparePartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is SparePartDetailLoaded && isEditing) {
            final part = state.sparePart;
            _nameController.text = part.name;
            _partNumberController.text = part.partNumber;
            _descriptionController.text = part.description ?? '';
            _unitPriceController.text = part.unitPrice.toString();
            _stockQtyController.text = part.stockQty.toString();
            _minStockController.text = part.minStock.toString();
            _imageUrlController.text = part.imageUrl ?? '';
            _selectedCategory = part.category ?? 'bearing';
            _selectedUnit = part.unit;
          }
        },
        child: SingleChildScrollView(
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
                    labelText: 'Name *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Part Number
                TextFormField(
                  controller: _partNumberController,
                  decoration: InputDecoration(
                    labelText: 'Part Number *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter part number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

                // Unit Price
                TextFormField(
                  controller: _unitPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Unit Price *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter unit price';
                    if (double.tryParse(value) == null) return 'Please enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Stock Qty & Min Stock
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockQtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock Qty',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _minStockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min Stock',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Unit
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'piece', child: Text('Piece')),
                    DropdownMenuItem(value: 'kg', child: Text('Kilogram')),
                    DropdownMenuItem(value: 'liter', child: Text('Liter')),
                    DropdownMenuItem(value: 'meter', child: Text('Meter')),
                    DropdownMenuItem(value: 'set', child: Text('Set')),
                  ],
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
                const SizedBox(height: 16),

                // Image URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                BlocBuilder<SparePartBloc, SparePartState>(
                  builder: (context, state) {
                    final isLoading = state is SparePartLoading;
                    return SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isEditing ? 'Update Spare Part' : 'Add Spare Part',
                                style: const TextStyle(fontSize: 16),
                              ),
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
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
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
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
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
    _imageUrlController.dispose();
    super.dispose();
  }
}
