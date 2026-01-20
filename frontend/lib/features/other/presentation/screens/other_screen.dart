import 'package:flutter/material.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/other/presentation/screens/password_reset_page.dart';
import 'package:frontend/features/other/presentation/widgets/profile_card.dart';
import 'package:frontend/features/other/presentation/screens/user_info_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/recipe/presentation/screens/meal_recommender_screen.dart';
import 'package:frontend/features/goal/presentation/screens/goal_list_screen.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  late String name;
  late DateTime createdAt;
  @override
  void initState() {
    super.initState();
    final currentUserService = Provider.of<CurrentUserService>(context, listen: false);
    final user = currentUserService.currentUser;
    if (user == null) {
      return;
    }
    setState(() {
      name = user.username ?? '?';
      createdAt = user.createdAt;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileCard(name: name, createdAt: createdAt),
            const SizedBox(height: 24),

            // General Section
            _buildSectionTitle('General'),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserInfo()));
                  },
                ),
                _buildDivider(),
                _buildListTile(icon: Icons.settings_outlined, title: 'Settings', onTap: () {}),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.lock_outline,
                  title: 'Password',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => const PasswordResetPage()));
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Log out',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: () async {
                    authService.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Features Section
            _buildSectionTitle('Features'),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.flag_outlined,
                  title: 'Goals',
                  subtitle: 'Set your nutrition targets',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalListScreen()));
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Meal Recommender',
                  subtitle: 'AI-powered meal suggestions',
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const MealRecommenderScreen()));
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dev Tools
            _buildSectionTitle('Developer', color: Colors.red),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildListTile(
                  icon: Icons.delete_forever,
                  title: 'Reset Database',
                  subtitle: 'Delete all local data & recreate',
                  iconColor: Colors.red,
                  titleColor: Colors.red,
                  onTap: () => _resetDatabase(context),
                ),
              ],
            ),
            _buildDivider(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widgety pomocnicze
  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: color ?? Colors.black87,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.black).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Colors.black, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: titleColor ?? Colors.black),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600]))
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 72, endIndent: 20, color: Colors.grey[200]);
  }

  // Db reset
  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Database?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'This will delete ALL data and recreate tables with sample data.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('RESET', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final dbService = Provider.of<LocalDatabaseService>(context, listen: false);

      try {
        await dbService.resetDatabase();
        await dbService.database;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Database reset successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }
}
