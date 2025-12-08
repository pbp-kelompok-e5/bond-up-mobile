import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:bond_up_mobile/features/home/presentation/screens/home_page.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/points_dashboard_screen.dart';
import 'package:bond_up_mobile/features/event-management/screens/my_events_page.dart';

/// App-wide navigation drawer
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Drawer(
      backgroundColor: AppColors.deepSea,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, request),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(title: 'BondUp Mobile'),
                ),
                (route) => false,
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'My Profile',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          const Divider(color: AppColors.deepSeaLight),
          _buildDrawerItem(
            context: context,
            icon: Icons.event,
            title: 'Events',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyEventsPage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.people,
            title: 'Find Partners',
            onTap: () {
              Navigator.pop(context);
              ToastUtils.showInfo(context, 'Find Partners feature coming soon!');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.leaderboard,
            title: 'Leaderboard',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.dashboard,
            title: 'Points Dashboard',
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PointsDashboardScreen(),
                ),
              );
            },
          ),
          const Divider(color: AppColors.deepSeaLight),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              ToastUtils.showInfo(context, 'Settings feature coming soon!');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.red,
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await _handleLogout(context, request);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, CookieRequest request) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: AppColors.deepSea,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.orangeSport,
            child: Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder(
            future: AuthService(request).getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (snapshot.data!.email != null)
                      Text(
                        snapshot.data!.email!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                  ],
                );
              }
              return const Text(
                'BondUp User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.orangeSport,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.deepSeaLight,
    );
  }

  Future<void> _handleLogout(BuildContext context, CookieRequest request) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSea,
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = AuthService(request);
      final success = await authService.logout();

      if (context.mounted) {
        if (success) {
          ToastUtils.showSuccess(context, 'Logged out successfully!');
        }

        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }
}
