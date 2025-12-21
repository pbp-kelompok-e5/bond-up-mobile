import 'dart:math'; 
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:flutter/material.dart';
import '../screens/user_profile_screen.dart';
import 'package:bond_up_mobile/core/constants/app_constants.dart';

class UserCard extends StatelessWidget {
  final UserMatchModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Rata atas biar rapi
          children: [
            // --- Avatar Section ---
            Container(
              padding: const EdgeInsets.all(2), // Ketebalan border
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.orangeSport, // Warna Border Orange
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 26, 
                backgroundColor: AppColors.deepSeaLighter,
                backgroundImage: NetworkImage(
                  user.profilePictureUrl.isNotEmpty
                      ? user.profilePictureUrl
                      : "https://ui-avatars.com/api/?name=${user.username}&background=random",
                ),
              ),
            ),
            
            const SizedBox(width: 24),

            // --- INFO SECTION ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nama User
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : user.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Username
                  Text(
                    "@${user.username}",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6), 
                      fontSize: 13
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Baris Kota
                  if (user.city.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.statusCompleted), // Icon Biru
                          const SizedBox(width: 4),
                          Text(
                            AppConstants.getCityDisplay(user.city),
                            style: const TextStyle(
                              color: AppColors.statusCompleted, 
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Baris Sport Chips
                  if (user.sports.isNotEmpty && user.sports != "No Sports")
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _buildSportChips(user.sports),
                    ),
                ],
              ),
            ),

            // Arrow Icon
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.arrow_forward_ios, 
                size: 14, 
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper: Chip Style ---
  Widget _buildCustomChip({required String label, Color? bgColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (bgColor ?? AppColors.orangeSport).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (bgColor ?? AppColors.orangeSport).withValues(alpha: 0.4), 
          width: 0.5
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10, 
          color: textColor ?? AppColors.orangeSport, 
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  // --- Helper: Logic Overflow (+2) ---
  List<Widget> _buildSportChips(String sportsString) {
    List<String> sports = sportsString.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    int maxVisible = 2; // Maksimal chip yang ditampilin langsung
    
    List<Widget> chips = [];

    // Loop sport yang mau ditampilin
    for (var i = 0; i < min(sports.length, maxVisible); i++) {
      chips.add(_buildCustomChip(label: sports[i]));
    }

    // Kalau ada sisa, tambahin chip "+X"
    if (sports.length > maxVisible) {
      int sisa = sports.length - maxVisible;
      chips.add(
        _buildCustomChip(
          label: "+$sisa", 
          bgColor: Colors.white, // Chip sisa warnanya beda (putih transparan)
          textColor: Colors.white70
        )
      );
    }

    return chips;
  }
}