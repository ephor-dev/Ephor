import 'package:ephor/ui/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/overview/widgets/gemini_insights_card.dart';
import 'package:ephor/ui/overview/widgets/group_analysis_section.dart';
import 'package:ephor/ui/overview/widgets/strategic_priorities_section.dart';
import 'package:ephor/ui/overview/widgets/top_stats_row.dart';
import 'package:flutter/material.dart';

class OverviewSubView extends StatefulWidget {
  final OverviewViewModel viewModel;
  const OverviewSubView({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _OverviewSubViewState();
}

class _OverviewSubViewState extends State<OverviewSubView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final hasReport = widget.viewModel.fullReport != null;
        final dateStr = widget.viewModel.lastUpdate;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Title and Last Updated
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Overview",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Last Update: $dateStr',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 2. Main Stats Row (Count + Chart + Activity)
              // This replaces the old 3-card row and the bottom row
              TopStatsRow(viewModel: widget.viewModel),
              
              const SizedBox(height: 24),

              // 3. Strategic Priorities (Overall Top 3)
              if (hasReport) ...[
                Text(
                  "Strategic Priorities", 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                StrategicPrioritiesSection(reportData: widget.viewModel.fullReport!),
                const SizedBox(height: 24),

                // 4. Campus Breakdown
                Text(
                  "Campus Analysis", 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                GroupAnalysisSection(
                  dataList: widget.viewModel.fullReport!['Group_Mean_Plans_Campus'] as List? ?? [],
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 24),

                // 5. Department/Office Breakdown
                Text(
                  "Departmental Analysis", 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                GroupAnalysisSection(
                  dataList: widget.viewModel.fullReport!['Group_Mean_Plans_Office_College'] as List? ?? [],
                  icon: Icons.business,
                ),
                const SizedBox(height: 24),

                // Gemini Insights
                Text(
                  "Gemini Insights", 
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                GeminiInsightsCard(insights: widget.viewModel.geminiInsights),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );
      },
    );
  }
}