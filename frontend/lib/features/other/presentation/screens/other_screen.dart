import 'package:flutter/material.dart';
import 'package:frontend/core/database/local_database_service.dart';
import 'package:frontend/features/temp/presentation/screens/user_info.dart';
import 'package:provider/provider.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Other')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserInfo()));
            },
          ),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () {}),

          const Divider(),

          // === DEV TOOLS ===
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Database', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Delete all local data & recreate'),
            onTap: () => _resetDatabase(context),
          ),
        ],
      ),
    );
  }

  Future<void> _resetDatabase(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text('This will delete ALL data and recreate tables with sample data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final dbService = Provider.of<LocalDatabaseService>(context, listen: false);

      try {
        await dbService.resetDatabase();

        // Force recreate
        await dbService.database;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Database reset successfully!'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}
