import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          'Employee Home',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}