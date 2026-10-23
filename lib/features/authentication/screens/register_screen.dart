import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/grade_level.dart';
import '../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedLevel;
  bool _passwordVisible = false;

  static const _levelMap = {
    'LKG': GradeLevel.kg,
    'UKG': GradeLevel.kg,
    'KG3': GradeLevel.kg,
  };

  static const _gradeLevelIntMap = {
    'LKG': 2,
    'UKG': 3,
    'KG3': 4,
  };

  static const _levels = ['LKG', 'UKG', 'KG3'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _sanitizeEmail(String value) => value.trim().toLowerCase();

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
          name: _nameController.text.trim(),
          email: _sanitizeEmail(_emailController.text),
          password: _passwordController.text,
          gradeLevel: _levelMap[_selectedLevel!]!,
          gradeLevelInt: _gradeLevelIntMap[_selectedLevel!]!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Please log in to continue.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          context.go(RouteNames.login);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return _buildScaffold(context, isLoading);
        },
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, bool isLoading) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBBDEFB), Color(0xFFFFE0B2)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -30,
                left: -30,
                child: _BlurCircle(color: const Color(0xFF90CAF9), size: 180),
              ),
              Positioned(
                bottom: -40,
                right: -40,
                child: _BlurCircle(color: const Color(0xFFFFCC80), size: 200),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // Logo placeholder
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 40,
                          color: AppColors.secondAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: AppTypography.kidsDisplayLg
                                          .copyWith(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Start your learning adventure today!',
                                      style: AppTypography.kidsBodyMd.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              _FieldLabel(label: "Child's Full Name"),
                              const SizedBox(height: 6),
                              _KidsTextField(
                                controller: _nameController,
                                hint: 'e.g. John Doe',
                                prefixIcon: Icons.person_rounded,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return "Child's name is required";
                                  }
                                  if (v.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),
                              _FieldLabel(label: 'Learning Level'),
                              const SizedBox(height: 6),
                              _KidsDropdown(
                                value: _selectedLevel,
                                items: _levels,
                                hint: 'Select a level',
                                onChanged: (v) =>
                                    setState(() => _selectedLevel = v),
                                validator: (_) => _selectedLevel == null
                                    ? 'Please select a learning level'
                                    : null,
                              ),

                              const SizedBox(height: 16),
                              _FieldLabel(label: "Parent's Email"),
                              const SizedBox(height: 6),
                              _KidsTextField(
                                controller: _emailController,
                                hint: 'parent@example.com',
                                prefixIcon: Icons.mail_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email address is required';
                                  }
                                  final email = v.trim().toLowerCase();
                                  final emailRegex = RegExp(
                                      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');
                                  if (!emailRegex.hasMatch(email)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),
                              _FieldLabel(label: 'Password'),
                              const SizedBox(height: 6),
                              _KidsTextField(
                                controller: _passwordController,
                                hint: 'Enter a strong password',
                                prefixIcon: Icons.lock_rounded,
                                obscureText: !_passwordVisible,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _passwordVisible = !_passwordVisible),
                                  child: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Minimum 8 characters with letters and numbers.',
                                style: AppTypography.kidsBodyMd.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),

                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: isLoading ? null : _onSignUp,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: isLoading
                                        ? AppColors.orange500
                                            .withValues(alpha: 0.7)
                                        : AppColors.orange500,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.orange500
                                            .withValues(alpha: 0.4),
                                        blurRadius: 14,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sign Up',
                                                style: AppTypography
                                                    .kidsHeadlineLg
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),
                              Center(
                                child: GestureDetector(
                                  onTap: () => context.go(RouteNames.login),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: AppTypography.kidsBodyMd.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Log In',
                                          style: AppTypography.kidsBodyMd
                                              .copyWith(
                                            color: AppColors.orange500,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 32,
                                        height: 1,
                                        color: AppColors.borderVariant),
                                    const SizedBox(width: 8),
                                    Icon(Icons.verified_user_rounded,
                                        size: 13,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'SAFE & SECURE',
                                      style: AppTypography.labelSm.copyWith(
                                        letterSpacing: 1.2,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                        width: 32,
                                        height: 1,
                                        color: AppColors.borderVariant),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.kidsBodyMd.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        fontSize: 15,
      ),
    );
  }
}

class _KidsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _KidsTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.kidsBodyMd
          .copyWith(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.kidsBodyMd.copyWith(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        prefixIcon:
            Icon(prefixIcon, size: 20, color: AppColors.secondAccent),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.orange500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        errorStyle: AppTypography.kidsBodyMd.copyWith(
          fontSize: 13,
          color: const Color(0xFFEF4444),
        ),
      ),
    );
  }
}

class _KidsDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _KidsDropdown({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      onChanged: onChanged,
      hint: Text(
        hint,
        style: AppTypography.kidsBodyMd.copyWith(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
      ),
      style: AppTypography.kidsBodyMd
          .copyWith(fontSize: 15, color: Colors.black87),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.school_rounded,
            size: 20, color: AppColors.secondAccent),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.orange500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        errorStyle: AppTypography.kidsBodyMd.copyWith(
          fontSize: 13,
          color: const Color(0xFFEF4444),
        ),
      ),
      items: items
          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
          .toList(),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
