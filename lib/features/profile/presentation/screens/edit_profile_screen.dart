import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
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
    // Only set city if it's not empty and exists in the city choices
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

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.updateProfile(
      fullName: _fullNameController.text.trim(),
      bio: _bioController.text.trim(),
      city: _selectedCity ?? '',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == true) {
      ToastUtils.showSuccess(context, response['message'] ?? 'Profile updated successfully');
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ToastUtils.showError(context, response['message'] ?? 'Failed to update profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.deepSea,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
              tooltip: 'Save',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeepSeaCard(
                header: const Row(
                  children: [
                    Icon(Icons.person, color: AppColors.orangeSport),
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
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'City',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.deepSeaLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      dropdownColor: AppColors.deepSeaLight,
                      style: const TextStyle(color: Colors.white),
                      hint: const Text(
                        'Select your city',
                        style: TextStyle(color: Colors.white54),
                      ),
                      value: _selectedCity,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _bioController,
                      hint: 'Tell us about yourself (optional)',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Save Changes',
                  onPressed: _isLoading ? null : _saveProfile,
                  size: ButtonSize.large,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Cancel',
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.large,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

