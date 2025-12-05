import 'package:flutter/material.dart';

class EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const EmptySearchState({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty ? 'No products found' : 'No results for "$searchQuery"',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Try a different search term', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ],
      ),
    );
  }
}
