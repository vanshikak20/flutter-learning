import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../student/student_home_screen.dart';
import '../employee/employee_home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../student/student_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  final role = await _authService.getUserRole();

  if (!mounted) return;

  // wrap navigation in addPostFrameCallback
  // this ensures navigation happens AFTER the current frame is done
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentShell()),
      );
    } else if (role == 'employee') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmployeeHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 80,
                color: AppColors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Smart Canteen',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order smart, skip the queue',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}