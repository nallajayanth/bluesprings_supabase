import 'package:flutter/material.dart';
import '../widgets/login_form_section.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very light grey/blue background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 450, // Constrain width for larger screens to match design
                      minHeight: constraints.maxHeight - 80, // Allow centering vertically
                    ),
                    child: const Center(
                      child: LoginFormSection(),
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
