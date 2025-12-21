import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/core/constants/app_constants.dart';

import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';

/// Screen for editing user profile
class EditProfileScreen extends StatefulWidget {
  final UserProfileModel profile;

  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _bioController;
  late String? _selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio);
    
    final profileCity = widget.profile.city;
    _selectedCity = (profileCity.isNotEmpty && AppConstants.cityChoices.containsKey(profileCity))
        ? profileCity
        : null;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    try {
      final response = await profileService.updateProfile(
        fullName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
        city: _selectedCity ?? '',
      );

      if (!mounted) return;

      if (response['status'] == true) {
        ToastUtils.showSuccess(context, response['message'] ?? 'Profile updated successfully');
        Navigator.pop(context, true);
      } else {
        ToastUtils.showError(context, response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showError(context, 'An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.deepSea,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeepSeaCard(
                  header: const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, color: AppColors.orangeSport),
                      SizedBox(width: 8),
                      Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- FULL NAME ---
                      AppTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        // PERBAIKAN: Menambahkan warna oranye eksplisit pada ikon
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.orangeSport),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // --- CITY DROPDOWN ---
                      const Text(
                        'City',
                        style: TextStyle(
                          color: AppColors.orangeSport,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCity,
                        items: AppConstants.sortedCities.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a city' : null,
                        
                        dropdownColor: AppColors.deepSeaLighter,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.orangeSport),
                        decoration: InputDecoration(
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: 'Select your city',
                          hintStyle: TextStyle(color: AppColors.orangeSport.withValues(alpha: 0.5)),
                          prefixIcon: const Icon(Icons.location_city_rounded, color: AppColors.orangeSport),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.orangeSport, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.orangeSportHover, width: 2.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.buttonDanger, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.buttonDanger, width: 2.0),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // --- BIO ---
                      AppTextField(
                        controller: _bioController,
                        label: 'Bio',
                        hint: 'Tell us about yourself...',
                        maxLines: 4,
                        // PERBAIKAN: Menambahkan warna oranye eksplisit pada ikon
                        prefixIcon: const Icon(Icons.article_outlined, color: AppColors.orangeSport),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                // --- ACTION BUTTONS ---
                AppButton(
                  text: 'Save Changes',
                  onPressed: _saveProfile,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: ButtonSize.large,
                  variant: ButtonVariant.primary,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Cancel',
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  isFullWidth: true,
                  size: ButtonSize.large,
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}