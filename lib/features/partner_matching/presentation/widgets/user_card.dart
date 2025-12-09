import 'package:bond_up_mobile/features/partner_matching/data/model/user_match_model.dart';
import 'package:flutter/material.dart';
import '../screens/user_profile_screen.dart';

class UserCard extends StatelessWidget {
  final UserMatchModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigasi ke UserProfileScreen dengan membawa ID user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: user.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.profilePictureUrl ?? "https://ui-avatars.com/api/?name=${user.username}"),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "@${user.username}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    
                    // Sports Chips (limit 2 biar gak overflow)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (user.city != null && user.city!.isNotEmpty)
                          _buildMiniChip(Icons.location_on, user.city!, Colors.blue),
                        
                        // Asumsi user.sports adalah String comma-separated "football, tennis"
                        // Sesuaikan dengan format data kamu
                        if (user.sports.isNotEmpty && user.sports != "No Sports")
                          ..._buildSportChips(user.sports),
                      ],
                    )
                  ],
                ),
              ),
              
              // Arrow Icon
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSportChips(String sportsString) {
    List<String> sports = sportsString.split(',');

    var displaySports = sports.take(3); 

    return displaySports.map((sport) {
      return _buildMiniChip(
        Icons.sports_soccer, 
        sport.trim(), 
        Colors.orange,
      );
    }).toList();
  }
}