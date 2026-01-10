import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/auth/services/current_user_service.dart';
import 'package:provider/provider.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your password must be at least 6 characters long',
                        style: TextStyle(fontSize: 13, color: Colors.grey[900]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Password fields
              _buildSectionTitle('Change your password'),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Current Password
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureCurrentPassword,
                      onToggleVisibility: () {
                        setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                      isFirst: true,
                    ),

                    _buildDivider(),

                    // New Password
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_reset,
                      obscureText: _obscureNewPassword,
                      onToggleVisibility: () {
                        setState(() => _obscureNewPassword = !_obscureNewPassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (value == _currentPasswordController.text) {
                          return 'New password must be different';
                        }
                        return null;
                      },
                    ),

                    _buildDivider(),

                    // Confirm Password
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      icon: Icons.lock,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Forgot password
              Center(
                child: TextButton(
                  onPressed: () {
                    _handleForgotPassword();
                  },
                  child: Text(
                    'Forgot your current password?',
                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget buildery

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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),

          // Text Field
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
                border: InputBorder.none,
                errorStyle: const TextStyle(fontSize: 12, height: 0.8),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 72, endIndent: 20, color: Colors.grey[200]);
  }

  // Handle Update

  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.changePassword(_currentPasswordController.text, _newPasswordController.text);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Password updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Go back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('$e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserService = Provider.of<CurrentUserService>(context, listen: false);
    final currentUser = currentUserService.currentUser;

    if (currentUser?.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email associated with this account'), backgroundColor: Colors.red),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send password reset email to:\n${currentUser!.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await authService.sendPasswordResetEmail(currentUser!.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent to ${currentUser.email}'),
          backgroundColor: Colors.green,
        ),
      );

      // Sign out user po wysłaniu emaila
      await authService.signOut();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send reset email: $e'), backgroundColor: Colors.red));
    }
  }
}
