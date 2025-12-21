import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/core/widgets/inputs/app_text_field.dart';
import 'package:bond_up_mobile/core/widgets/buttons/app_button.dart';
import 'package:bond_up_mobile/core/utils/toast_utils.dart';

import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Focus Nodes untuk navigasi keyboard yang smooth
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Tutup keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    try {
      TextInput.finishAutofillContext();

      final response = await authService.register(
        _usernameController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (response.status) {
        // SUKSES
        ToastUtils.showSuccess(context, 'Registration successful! Please login.');
        
        // Kembali ke login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        // GAGAL
        ToastUtils.showError(context, response.message);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, 'An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Membuat body meluas ke belakang AppBar agar gradient full screen
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.white, // Tombol back putih
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepSea,
                AppColors.deepSeaLighter,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48.0 : 24.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 480 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- 1. LOGO ---
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/logo_bondup.png',
                          height: isTablet ? 100 : 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.whiteWithOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.sports_handball_rounded,
                                size: 48,
                                color: AppColors.orangeSport,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- 2. CARD REGISTER ---
                      Container(
                        padding: EdgeInsets.all(isTablet ? 40.0 : 28.0),
                        decoration: BoxDecoration(
                          color: AppColors.deepSea.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create Account',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Join BondUp and find your sports partner',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.gray300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // --- INPUT USERNAME ---
                                AppTextField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocus,
                                  label: 'Username',
                                  hint: 'Choose a username',
                                  prefixIcon: const Icon(
                                    Icons.person_outline, 
                                    color: AppColors.orangeSport,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passwordFocus);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username';
                                    }
                                    if (value.length < 3) {
                                      return 'Username must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // --- INPUT PASSWORD ---
                                AppTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  label: 'Password',
                                  hint: 'Create a password',
                                  obscureText: true,
                                  enablePasswordToggle: true, // Toggle mata aktif
                                  prefixIcon: const Icon(
                                    Icons.lock_outline, 
                                    color: AppColors.orangeSport,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // --- INPUT CONFIRM PASSWORD ---
                                AppTextField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocus,
                                  label: 'Confirm Password',
                                  hint: 'Re-enter your password',
                                  obscureText: true,
                                  enablePasswordToggle: true, // Toggle mata aktif
                                  prefixIcon: const Icon(
                                    Icons.lock_clock_outlined, // Sedikit beda ikon untuk variasi visual
                                    color: AppColors.orangeSport,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleRegister(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),

                                // --- BUTTON REGISTER ---
                                AppButton(
                                  text: 'Register',
                                  onPressed: _handleRegister,
                                  isLoading: _isLoading,
                                  isFullWidth: true,
                                  size: ButtonSize.medium,
                                  variant: ButtonVariant.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- LOGIN LINK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Kembali ke Login
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.orangeSport,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}