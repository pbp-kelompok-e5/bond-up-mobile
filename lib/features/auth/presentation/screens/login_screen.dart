import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final authService = AuthService(request);

    try {
      final response = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.status) {
        // Login successful
        ToastUtils.showSuccess(
          context,
          '${response.message} Welcome, ${response.username}!',
        );

        // Navigate to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'BondUp Mobile'),
          ),
        );
      } else {
        // Login failed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: Text(response.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, 'An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
=======
      backgroundColor: AppColors.deepSea,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
                  // Logo or App Name
                  Text(
                    'BondUp',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.orangeSport,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find Your Sports Partner',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
<<<<<<< HEAD
                          color: AppColors.gray600,
=======
                          color: AppColors.white.withValues(alpha: 0.8),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Username field
                  AppTextField(
                    controller: _usernameController,
                    label: 'Username',
                    hint: 'Enter your username',
<<<<<<< HEAD
                    prefixIcon: const Icon(Icons.person_outline),
=======
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.white),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: true,
<<<<<<< HEAD
                    prefixIcon: const Icon(Icons.lock_outline),
=======
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.white),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Login button
                  AppButton(
                    text: 'Login',
                    onPressed: _isLoading ? null : _handleLogin,
                    isFullWidth: true,
                    isLoading: _isLoading,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
<<<<<<< HEAD
                        style: Theme.of(context).textTheme.bodyMedium,
=======
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white,
                            ),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
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
                        child: Text(
                          'Register',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.orangeSport,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                ],
=======
                  ],
                ),
>>>>>>> 5b6033e392d1d03612b89f4c721dbbe03549a053
              ),
            ),
          ),
        ),
      ),
    );
  }
}

