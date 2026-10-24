import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/router/route_names.dart';
import '../services/dio_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DioAuthService()
          .forgotPassword(_emailController.text.trim().toLowerCase());
      if (mounted) {
        context.go(
          RouteNames.verifyOtp,
          extra: _emailController.text.trim().toLowerCase(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background glows
          Positioned(
            top: -60,
            right: -60,
            child: _GlowCircle(
                color: AppColors.orange500.withValues(alpha: 0.08),
                size: 300),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowCircle(
                color: AppColors.navy700.withValues(alpha: 0.06),
                size: 280),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // Lock reset icon
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.orange500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 44,
                      color: AppColors.secondAccent,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title
                  Text(
                    'Forgot Password?',
                    style: AppTypography.displayLg.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "No worries! Enter your school email address and we'll send you instructions to reset your password.",
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // White card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppTypography.bodyMdMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTypography.bodyMd
                                .copyWith(fontSize: 15, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'student@example.com',
                              hintStyle: AppTypography.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                              prefixIcon: const Icon(
                                Icons.mail_outline_rounded,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.containerHigh,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.orange500, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFEF4444), width: 2),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email address is required';
                              }
                              final emailRegex = RegExp(
                                  r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
                              if (!emailRegex
                                  .hasMatch(v.trim().toLowerCase())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orange500,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.orange500.withValues(alpha: 0.7),
                                elevation: 0,
                                shape: const StadiumBorder(),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, size: 20),
                              label: Text(
                                _isLoading ? 'Sending...' : 'Send Instructions',
                                style: AppTypography.titleMd.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back to Login
                  GestureDetector(
                    onTap: () => context.go(RouteNames.login),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Back to Login',
                          style: AppTypography.bodyMdMedium.copyWith(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Text(
                    '© 2024 Kuta Learning. All rights reserved.',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
