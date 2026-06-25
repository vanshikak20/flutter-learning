import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/order_status.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'student_shell.dart';


class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Track Order'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<OrderModel>(
        stream: FirestoreService().getOrderStream(order.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          final liveOrder = snapshot.data ?? order;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildStatusHeader(liveOrder),
                const SizedBox(height: 32),
                _buildTokenCard(liveOrder),
                const SizedBox(height: 24),
                _buildStatusStepper(liveOrder),
                const SizedBox(height: 24),
                _buildOrderSummary(liveOrder),
                const SizedBox(height: 32),
                _buildBackButton(context, liveOrder),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel liveOrder) {
    final isReady = liveOrder.status == OrderStatus.ready;
    final isCompleted = liveOrder.status == OrderStatus.completed;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isReady || isCompleted
                ? AppColors.success
                : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted
                ? Icons.check_circle
                : isReady
                    ? Icons.notifications_active
                    : Icons.restaurant,
            color: Colors.white,
            size: 52,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getHeaderText(liveOrder.status),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getSubText(liveOrder.status),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getHeaderText(String status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Received!';
      case OrderStatus.preparing:
        return 'Being Prepared...';
      case OrderStatus.ready:
        return 'Order is Ready!';
      case OrderStatus.completed:
        return 'Enjoy your meal!';
      default:
        return 'Order Placed';
    }
  }

  String _getSubText(String status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for canteen to start preparing';
      case OrderStatus.preparing:
        return 'Your food is being prepared fresh';
      case OrderStatus.ready:
        return 'Please collect your order from the counter';
      case OrderStatus.completed:
        return 'Thank you for ordering from Smart Canteen';
      default:
        return '';
    }
  }

  Widget _buildTokenCard(OrderModel liveOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Token Number',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#${liveOrder.tokenNumber}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Est. wait: ${liveOrder.estimatedWaitMinutes} mins',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStepper(OrderModel liveOrder) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.completed,
    ];

    final currentIndex = statuses.indexOf(liveOrder.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final status = statuses[index];
          final isDone = index < currentIndex;
          final isCurrent = index == currentIndex;
          final isLast = index == statuses.length - 1;
          final statusColor = Color(OrderStatus.getColor(status));

          return Row(
            children: [
              // left side — circle + line
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDone || isCurrent
                          ? statusColor
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check
                          : isCurrent
                              ? Icons.radio_button_checked
                              : Icons.circle_outlined,
                      color: isDone || isCurrent
                          ? Colors.white
                          : Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: isDone
                          ? AppColors.primary
                          : Colors.grey.shade200,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // right side — label
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        OrderStatus.getLabel(status),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrent
                              ? AppColors.textDark
                              : isDone
                                  ? AppColors.textLight
                                  : Colors.grey.shade400,
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          _getSubText(status),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderSummary(OrderModel liveOrder) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...liveOrder.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity}x ${item.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '₹${liveOrder.totalAmount.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildBackButton(BuildContext context, OrderModel liveOrder) {
  final isCompleted = liveOrder.status == OrderStatus.completed;

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentShell(),
          ),
          (route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isCompleted
            ? AppColors.success
            : AppColors.primary,
      ),
      child: Text(
        isCompleted ? 'Done' : 'Back to Menu',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
  );
 }
}