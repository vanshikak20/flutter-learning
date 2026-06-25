import 'package:flutter/material.dart';
import '../core/constants/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(OrderStatus.getColor(status)).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Color(OrderStatus.getColor(status)),
          width: 1,
        ),
      ),
      child: Text(
        OrderStatus.getLabel(status),
        style: TextStyle(
          color: Color(OrderStatus.getColor(status)),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}