import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/spare_part/spare_part_bloc.dart';
import '../../blocs/spare_part/spare_part_event.dart';
import '../../blocs/spare_part/spare_part_state.dart';
import 'spare_part_detail_page.dart';
import 'add_edit_spare_part_page.dart';

class SparePartListPage extends StatefulWidget {
  const SparePartListPage({super.key});

  @override
  State<SparePartListPage> createState() => _SparePartListPageState();
}

class _SparePartListPageState extends State<SparePartListPage> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _selectedLowStock;

  @override
  void initState() {
    super.initState();
    context.read<SparePartBloc>().add(LoadSpareParts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Parts'),
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
                MaterialPageRoute(builder: (context) => const AddEditSparePartPage()),
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
                hintText: 'Search spare parts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SparePartBloc>().add(LoadSpareParts());
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                context.read<SparePartBloc>().add(SearchSpareParts(query: value));
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
                  _buildCategoryFilter('All', null),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Bearing', 'bearing'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Belt', 'belt'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Filter', 'filter'),
                  const SizedBox(width: 8),
                  _buildCategoryFilter('Oil', 'oil'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Spare Part List
          Expanded(
            child: BlocBuilder<SparePartBloc, SparePartState>(
              builder: (context, state) {
                if (state is SparePartLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SparePartError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<SparePartBloc>().add(LoadSpareParts()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SparePartListLoaded) {
                  if (state.spareParts.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No spare parts found'),
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
                              'Total: ${state.total} parts',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.spareParts.length} showing',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      // List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<SparePartBloc>().add(LoadSpareParts());
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: state.spareParts.length,
                            itemBuilder: (context, index) {
                              final part = state.spareParts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getStockStatusColor(part.stockStatus),
                                    child: const Icon(Icons.inventory, color: Colors.white),
                                  ),
                                  title: Text(
                                    part.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Part No: ${part.partNumber}',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                      Row(
                                        children: [
                                          _buildStockStatusChip(part.stockStatus),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Stock: ${part.stockQty} ${part.unit}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        part.unitPriceLabel,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        part.totalValueLabel,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider.value(
                                          value: context.read<SparePartBloc>(),
                                          child: SparePartDetailPage(partId: part.partId),
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

  Widget _buildCategoryFilter(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = category);
        context.read<SparePartBloc>().add(LoadSpareParts(category: category));
      },
      selectedColor: const Color(0xFF1E40AF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1E40AF),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Spare Parts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildLowStockFilterChip('All', null),
                _buildLowStockFilterChip('Low Stock', true),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedLowStock = null;
              });
              context.read<SparePartBloc>().add(LoadSpareParts());
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

  Widget _buildLowStockFilterChip(String label, bool? lowStock) {
    final isSelected = _selectedLowStock == lowStock;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedLowStock = lowStock);
        context.read<SparePartBloc>().add(LoadSpareParts(lowStock: lowStock));
        Navigator.pop(context);
      },
      selectedColor: Colors.orange.withOpacity(0.2),
      checkmarkColor: Colors.orange,
    );
  }

  Widget _buildStockStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStockStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: _getStockStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'in_stock':
        return Colors.green;
      case 'low_stock':
        return Colors.orange;
      case 'out_of_stock':
        return Colors.red;
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
