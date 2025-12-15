import 'package:flutter/material.dart';

class GroupStatCard extends StatelessWidget {
  final String groupName;
  final double? rating;
  final String? primaryFocus;
  final String? secondaryFocus;
  final IconData icon;

  const GroupStatCard({
    super.key, 
    required this.groupName,
    required this.rating,
    required this.primaryFocus,
    required this.secondaryFocus,
    required this.icon,
  });

  String _cleanFocus(String? focus) {
    if (focus == null) return "N/A";
    return focus.split('(').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.brightnessOf(context) == Brightness.light ? Colors.white : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Icon(icon, size: 16, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  groupName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (rating ?? 0) > 3.5 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${rating?.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: (rating ?? 0) > 3.5 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            "Primary Focus:", 
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            _cleanFocus(primaryFocus),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            "Secondary Focus:", 
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          Text(
            _cleanFocus(secondaryFocus),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}