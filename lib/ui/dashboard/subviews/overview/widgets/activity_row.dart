import 'package:flutter/material.dart';

class ActivityRow extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final bool isIdentified;

  const ActivityRow({
    super.key, 
    required this.name,
    required this.time,
    required this.status,
    required this.isIdentified,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.surfaceContainerLowest),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: isIdentified ? const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0) : const Color.fromARGB(255, 122, 122, 122),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(status, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}