import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

/// Dialog for uploading profile image URL
class UploadImageDialog extends StatefulWidget {
  const UploadImageDialog({super.key});

  @override
  State<UploadImageDialog> createState() => _UploadImageDialogState();
}

class _UploadImageDialogState extends State<UploadImageDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.deepSeaLight,
      title: const Text(
        'Upload Profile Image',
        style: TextStyle(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the URL of your profile image:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _controller,
              hint: 'https://example.com/image.jpg',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an image URL';
                }
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return 'URL must start with http:// or https://';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: The URL should point to a publicly accessible image.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeSport,
            foregroundColor: Colors.white,
          ),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

