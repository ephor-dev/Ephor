import 'package:flutter/material.dart';

class PriorityCard extends StatelessWidget {
  final int rank;
  final double score;
  final String code;
  final String description;

  const PriorityCard({
    super.key, 
    required this.rank, 
    required this.score, 
    required this.code, 
    required this.description
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = rank == 1 
        ? Theme.of(context).colorScheme.primary
        : rank == 2 
            ? Theme.of(context).colorScheme.tertiary
            : Colors.grey;

    return Container(
      height: 140,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "#$rank Priority",
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Text(
                code, 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[500])
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "Mean: $score",
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          )
        ],
      ),
    );
  }
}