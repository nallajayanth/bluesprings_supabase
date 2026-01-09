import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/header_section.dart';
import '../widgets/login_form_section.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the background behind the status bar matches the gradient
      backgroundColor: AppColors.gradientStart, 
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: HeaderSection(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: const LoginFormSection(),
          ),
        ],
      ),
    );
  }
}
