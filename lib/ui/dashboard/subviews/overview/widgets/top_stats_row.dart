import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/overview/widgets/recent_activity_card.dart';
import 'package:ephor/ui/dashboard/subviews/overview/widgets/stat_card.dart';
import 'package:ephor/ui/dashboard/subviews/overview/widgets/training_needs_chart_card.dart';
import 'package:flutter/material.dart';

class TopStatsRow extends StatelessWidget {
  final OverviewViewModel viewModel;
  const TopStatsRow({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // 350 is the height of the chart/activity cards
    const double commonHeight = 350; 

    return LayoutBuilder(
      builder: (context, constraints) {
        // 1. The Count Card (Modified to match height)
        final countCard = StatCard(
          title: "Training Needs Identified",
          value: "${viewModel.trainingNeedsCount}",
          subtitle: "Total identified needs",
          color: const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0),
          height: commonHeight, // Match height of neighbors
        );

        // 2. The Chart Card
        final chartCard = TrainingNeedsChartCard(viewModel: viewModel);

        // 3. The Activity Card
        final activityCard = RecentActivityCard(viewModel: viewModel);

        // Desktop Layout (> 1300 width)
        if (constraints.maxWidth > 1300) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: countCard),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: chartCard),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: activityCard),
            ],
          );
        } 
        // Tablet/Laptop Layout (> 900 width)
        else if (constraints.maxWidth > 900) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: countCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 3, child: chartCard),
                ],
              ),
              const SizedBox(height: 20),
              activityCard // Full width activity on tablet
            ],
          );
        } 
        // Mobile Layout
        else {
          return Column(
            children: [
              SizedBox(height: 220, child: StatCard(
                title: "Training Needs Identified",
                value: "${viewModel.trainingNeedsCount}",
                subtitle: "Total identified needs",
                color: const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0),
                height: 220, // Smaller height for mobile
              )),
              const SizedBox(height: 16),
              chartCard,
              const SizedBox(height: 16),
              activityCard,
            ],
          );
        }
      },
    );
  }
}