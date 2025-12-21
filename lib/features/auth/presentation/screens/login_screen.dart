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
import 'package:bond_up_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:bond_up_mobile/features/home/presentation/screens/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    try {
      TextInput.finishAutofillContext(); 

      final response = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.status) {
        ToastUtils.showSuccess(context, 'Welcome back, ${response.username}!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: 'BondUp Mobile')),
        );
      } else {
        ToastUtils.showError(context, response.message);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, 'Connection failed: ${e.toString()}');
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.deepSea,       // #00063D
                AppColors.deepSeaLighter,// #2A2F6C
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
                            // Fallback jika gambar belum diload
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

                      // --- 2. CARD FORM ---
                      Container(
                        padding: EdgeInsets.all(isTablet ? 40.0 : 28.0),
                        decoration: BoxDecoration(
                          // Background transparan gelap agar teks putih terbaca
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
                                  'Welcome Back!',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to find your sports partner',
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
                                  hint: 'Enter your username',
                                  // PERBAIKAN: Set warna ikon secara eksplisit agar tidak gelap
                                  prefixIcon: const Icon(
                                    Icons.person_outline, 
                                    color: AppColors.orangeSport, 
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_passwordFocus);
                                  },
                                  validator: (v) => v!.isEmpty ? 'Username required' : null,
                                ),
                                const SizedBox(height: 20),

                                // --- INPUT PASSWORD ---
                                AppTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  obscureText: true, // Default tertutup
                                  enablePasswordToggle: true, // FITUR BARU: Aktifkan toggle mata
                                  // PERBAIKAN: Set warna ikon kunci secara eksplisit
                                  prefixIcon: const Icon(
                                    Icons.lock_outline, 
                                    color: AppColors.orangeSport, 
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  validator: (v) => v!.isEmpty ? 'Password required' : null,
                                ),
                                
                                const SizedBox(height: 32),

                                // --- TOMBOL LOGIN ---
                                AppButton(
                                  text: 'Sign In',
                                  onPressed: _handleLogin,
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

                      // --- REGISTER LINK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Sign Up',
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