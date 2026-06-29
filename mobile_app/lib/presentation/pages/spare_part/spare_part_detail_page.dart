import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/spare_part/spare_part_bloc.dart';
import '../../blocs/spare_part/spare_part_event.dart';
import '../../blocs/spare_part/spare_part_state.dart';
import '../../../core/constants/app_colors.dart';
import 'add_edit_spare_part_page.dart';

class SparePartDetailPage extends StatefulWidget {
  final String partId;

  const SparePartDetailPage({super.key, required this.partId});

  @override
  State<SparePartDetailPage> createState() => _SparePartDetailPageState();
}

class _SparePartDetailPageState extends State<SparePartDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SparePartBloc>().add(LoadSparePartDetail(partId: widget.partId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('รายละเอียดอะไหล่', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('แก้ไข'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'stock',
                child: Row(
                  children: [
                    Icon(Icons.inventory, size: 20),
                    SizedBox(width: 8),
                    Text('อัพเดท Stock'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('ลบ', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<SparePartBloc, SparePartState>(
        builder: (context, state) {
          if (state is SparePartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SparePartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.read<SparePartBloc>().add(
                      LoadSparePartDetail(partId: widget.partId),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('ลองใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SparePartDetailLoaded) {
            final part = state.sparePart;
            final hasImage = part.imageUrl != null && part.imageUrl!.isNotEmpty;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  if (hasImage)
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                      child: Image.network(
                        'http://localhost:8000${part.imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                      child: _buildImagePlaceholder(),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getStockStatusColor(part.stockStatus).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.inventory,
                                        color: _getStockStatusColor(part.stockStatus),
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            part.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Part No: ${part.partNumber}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildStockStatusChip(part.stockStatus),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stock Info Card
                        _buildCard(
                          title: 'ข้อมูล Stock',
                          icon: Icons.inventory_2,
                          child: Column(
                            children: [
                              _buildInfoRow('จำนวนคงเหลือ', '${part.stockQty} ${part.unit}'),
                              _buildInfoRow('ขั้นต่ำ', '${part.minStock} ${part.unit}'),
                              _buildInfoRow('มูลค่ารวม', part.totalValueLabel),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showUpdateStockDialog(),
                                  icon: const Icon(Icons.update),
                                  label: const Text('อัพเดท Stock'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Details Card
                        _buildCard(
                          title: 'รายละเอียด',
                          icon: Icons.info_outline,
                          child: Column(
                            children: [
                              _buildInfoRow('ราคาต่อหน่วย', part.unitPriceLabel),
                              _buildInfoRow('หมวดหมู่', part.category ?? '-'),
                              if (part.description != null && part.description!.isNotEmpty)
                                _buildInfoRow('รายละเอียด', part.description!),
                              _buildInfoRow('สถานะ', part.isActive ? 'ใช้งาน' : 'ไม่ใช้งาน'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Timestamps Card
                        _buildCard(
                          title: 'วันที่',
                          icon: Icons.access_time,
                          child: Column(
                            children: [
                              _buildInfoRow('สร้างเมื่อ', _formatDateTime(part.createdAt)),
                              _buildInfoRow('อัพเดทล่าสุด', _formatDateTime(part.updatedAt)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Button
                        if (part.stockStatus == 'low_stock' || part.stockStatus == 'out_of_stock')
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppColors.warningGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _showUpdateStockDialog(),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('สั่งซื้ออะไหล่'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text(
          'ไม่มีรูปภาพ',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStockStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStockStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStockStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: _getStockStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'in_stock':
        return AppColors.success;
      case 'low_stock':
        return AppColors.warning;
      case 'out_of_stock':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<SparePartBloc>(),
              child: AddEditSparePartPage(partId: widget.partId),
            ),
          ),
        );
        break;
      case 'stock':
        _showUpdateStockDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showUpdateStockDialog() {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('อัพเดท Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'จำนวน (+ เพิ่ม, - ลด)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'เหตุผล',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null) {
                context.read<SparePartBloc>().add(UpdateStock(
                  partId: widget.partId,
                  quantity: quantity,
                  reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                ));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('อัพเดท'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ลบอะไหล่'),
        content: const Text('คุณต้องการลบอะไหล่นี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SparePartBloc>().add(DeleteSparePart(partId: widget.partId));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
