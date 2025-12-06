import 'package:ephor/ui/catna_form/view_model/catna_viewmodel.dart';
import 'package:ephor/utils/responsiveness.dart';
import 'package:flutter/material.dart';

class CatnaStartView extends StatelessWidget {
  final CatnaViewModel viewModel;

  const CatnaStartView({
    super.key,
    required this.viewModel
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Center(
      child: FractionallySizedBox(
        widthFactor: isMobile ? 1.0 : 0.75,
        heightFactor: 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer, // Light red background
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary, // Accent Red
                ),
              ),
              const SizedBox(height: 32),
            
              // 2. Title
              Text(
                "CATNA Preparation",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            
              // 3. Description
              Text(
                "You are about to start a CATNA. Please ensure you have a stable internet connection and fill all that which applies.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            
              // 4. Details List (Simpler clean layout)
              _buildDetailRow(context, Icons.book_outlined, "Knowledge", "9 items"),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.handyman_outlined, "Skills", "9 items"),
              const SizedBox(height: 12),
              _buildDetailRow(context, Icons.sentiment_satisfied_alt_outlined, "Attitude", "9 items"),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer, // Slight grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}