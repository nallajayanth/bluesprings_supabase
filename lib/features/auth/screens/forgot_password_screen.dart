import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey/blue background matcher
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Top Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                
                const SizedBox(height: 48),

                // Icon Logo
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFE2EE), // Light grayish-blue for icon background
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.contact_mail_outlined, 
                          color: Color(0xFF1E40AF), // Dark blue icon color
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Titles
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B), // Slate 800
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Enter your registered phone or email to reset\nyour password. We\'ll send a secure link to\nyour inbox.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: const Color(0xFF64748B), // Slate 500
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Field Label
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Phone or Email',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155), // Slate 700
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Input Field
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: TextField(
                    controller: _identifierController,
                    style: GoogleFonts.inter(fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: const Icon(
                        Icons.alternate_email,
                        color: Color(0xFF94A3B8), // Slate 400
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF10B981)), // Teal focus
                      ),
                      hintText: 'e.g. hello@mygate.com',
                      hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2563EB), // Blue 600
                          Color(0xFF10B981), // Emerald 500
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement send link logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send Reset Link',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.send_outlined, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
