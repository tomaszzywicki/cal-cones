import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:frontend/features/user/presentation/screens/onboarding.dart';
import 'package:frontend/features/user/presentation/screens/profile_edition_screens/edit_diet_screen.dart';
import 'package:frontend/features/user/presentation/widgets/macro_split_indicator.dart';
import 'package:provider/provider.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserService = Provider.of<CurrentUserService>(context, listen: true);
    final user = currentUserService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'User Info',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _buildSectionTitle('Account Information'),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? 'N/A',
                  isFirst: true,
                ),
                _buildDivider(),
                _buildInfoTile(icon: Icons.person_outline, label: 'Username', value: user?.username ?? 'N/A'),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.fingerprint,
                  label: 'User ID',
                  value: user?.uid ?? 'N/A',
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- NOWA SEKCJA: Personal Details ---
            _buildSectionTitle('Personal Details'),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildInfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  // Używamy gettera 'age' z UserEntity
                  value: user?.age?.toString() ?? 'N/A',
                  isFirst: true,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: user?.sex == 'MALE' ? Icons.male : Icons.female,
                  label: 'Sex',
                  value: _formatTileDescription(user?.sex),
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.height,
                  label: 'Height',
                  value: user?.height != null ? '${user!.height} cm' : 'N/A',
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.restaurant,
                  label: 'Diet Type',
                  value: _formatTileDescription(user?.dietType),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditDietScreen()));
                  },
                  trailingWidget: MacroSplitIndicator(
                    split: user?.macroSplit?.map((key, value) => MapEntry(key, value.toInt())),
                  ),
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.directions_run,
                  label: 'Activity Level',
                  value: _formatTileDescription(user?.activityLevel),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 24),
            // -------------------------------------

            // Status section
            _buildSectionTitle('Status'),
            const SizedBox(height: 8),
            _buildSection(
              children: [
                _buildInfoTile(
                  icon: Icons.check_circle_outline,
                  label: 'Setup Completed',
                  value: user?.setupCompleted == true ? 'Yes' : 'No',
                  valueColor: user?.setupCompleted == true ? Colors.green : Colors.orange,
                  isFirst: true,
                  onTap: (user != null && !user.setupCompleted)
                      ? () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (context) => const Onboarding()));
                        }
                      : null,
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value: user?.createdAt != null ? _formatDate(user!.createdAt) : 'N/A',
                ),
                _buildDivider(),
                _buildInfoTile(
                  icon: Icons.update_outlined,
                  label: 'Last Modified',
                  value: user?.lastModifiedAt != null ? _formatDate(user!.lastModifiedAt) : 'N/A',
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context, authService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widgety pomocnicze

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(16) : Radius.zero,
              bottom: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: valueColor ?? Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Spacer(),
              if (trailingWidget != null) ...[trailingWidget, const SizedBox(width: 16)],

              if (onTap != null) const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 72, endIndent: 20, color: Colors.grey[200]);
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authService.signOut();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    }
  }

  String _formatTileDescription(String? dietType) {
    if (dietType == null) return 'N/A';
    return dietType
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
