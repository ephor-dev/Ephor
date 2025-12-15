import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GeminiInsightsCard extends StatelessWidget {
  final String insights;


  const GeminiInsightsCard({
    super.key, 
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
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
                child: Icon(Icons.auto_awesome, size: 16, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Summarization',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          MarkdownBody(
            data: insights,
          )
        ],
      ),
    );
  }
}