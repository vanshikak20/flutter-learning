import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/order_status.dart';
import '../../models/order_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/employee_order_card.dart';
import '../auth/login_screen.dart';
import 'employee_menu_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = [
    {'label': 'All Active', 'value': 'all'},
    {'label': 'Pending', 'value': OrderStatus.pending},
    {'label': 'Preparing', 'value': OrderStatus.preparing},
    {'label': 'Ready', 'value': OrderStatus.ready},
  ];

  List<OrderModel> _applyFilter(List<OrderModel> orders) {
    if (_selectedFilter == 'all') return orders;
    return orders
        .where((o) => o.status == _selectedFilter)
        .toList();
  }

  Future<void> _updateStatus(OrderModel order) async {
    final nextStatus = OrderStatus.getNextStatus(order.status);
    if (nextStatus == null) return;

    try {
      await _firestoreService.updateOrderStatus(order.id, nextStatus);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Orders Dashboard'),
        actions: [
          IconButton(
          icon: const Icon(Icons.restaurant_menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeeMenuScreen(),
              ),
            );
          },
        ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getActiveOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final allOrders = snapshot.data ?? [];
                final filtered = _applyFilter(allOrders);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'all'
                              ? 'No active orders'
                              : 'No ${OrderStatus.getLabel(_selectedFilter).toLowerCase()} orders',
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return EmployeeOrderCard(
                      order: order,
                      onStatusUpdate: () => _updateStatus(order),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = filter['value'] == _selectedFilter;
            return GestureDetector(
              onTap: () => setState(
                () => _selectedFilter = filter['value']!,
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter['label']!,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}