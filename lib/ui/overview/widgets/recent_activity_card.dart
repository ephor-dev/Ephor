import 'package:ephor/ui/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/overview/widgets/activity_row.dart';
import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  final OverviewViewModel viewModel;
  const RecentActivityCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Card(
        color: Theme.brightnessOf(context) == Brightness.light
          ? Colors.white
          : Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Theme.of(context).colorScheme.onSurface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Activity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3, 
                      child: Text("Employee", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))
                    ),
                    Expanded(
                      flex: 2, 
                      child: Text("Enrolled", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))
                    ),
                    Expanded(
                      flex: 2, 
                      child: Text("Status", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12))
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                    itemCount: viewModel.recentActivity.length,
                    itemBuilder: (context, index) {
                      final activity = viewModel.recentActivity[index];
                      return ActivityRow(
                        name: activity.employeeName,
                        time: activity.timeAgo,
                        status: activity.status,
                        isIdentified: activity.status == "Identified",
                      );
                    },
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }
}