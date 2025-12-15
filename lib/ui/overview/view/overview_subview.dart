import 'package:ephor/ui/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/overview/widgets/gemini_insights_card.dart';
import 'package:ephor/ui/overview/widgets/group_analysis_section.dart';
import 'package:ephor/ui/overview/widgets/strategic_priorities_section.dart';
import 'package:ephor/ui/overview/widgets/top_stats_row.dart';
import 'package:ephor/utils/custom_message_exception.dart';
import 'package:ephor/utils/overview_args.dart';
import 'package:ephor/utils/results.dart';
import 'package:flutter/material.dart';

class OverviewSubView extends StatefulWidget {
  final OverviewViewModel viewModel;
  const OverviewSubView({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _OverviewSubViewState();
}

class _OverviewSubViewState extends State<OverviewSubView> {
  @override
  void initState() {
    widget.viewModel.screenshot.addListener(_onScreenshot);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OverviewSubView oldWidget) {
    if (widget.viewModel.screenshot != oldWidget.viewModel.screenshot) {
      widget.viewModel.screenshot.addListener(_onScreenshot);
      oldWidget.viewModel.screenshot.removeListener(_onScreenshot);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.viewModel.screenshot.removeListener(_onScreenshot);
    super.dispose();
  }

  void _onScreenshot() {
    if (widget.viewModel.screenshot.completed) {
      Ok result = widget.viewModel.screenshot.result as Ok;
      widget.viewModel.screenshot.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved the overview at ${result.value}!"),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (widget.viewModel.screenshot.error) {
      Error error = widget.viewModel.screenshot.result as Error;
      CustomMessageException messageException = error.error as CustomMessageException;
      widget.viewModel.screenshot.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saving Error: ${messageException.message}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _OverviewContent(
            viewModel: widget.viewModel,
            onSaveRequest: () {
              widget.viewModel.screenshot.execute((
                OverviewArgs(
                  context, 
                  _OverviewContent(
                    viewModel: widget.viewModel
                  )
                )
              ));
            }
          )
        );
      },
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.viewModel,
    this.onSaveRequest
  });

  final OverviewViewModel viewModel;
  final VoidCallback? onSaveRequest;

  @override
  Widget build(BuildContext context) {
    final hasReport = viewModel.fullReport != null;
    final dateStr = viewModel.lastUpdate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Overview",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (hasReport) Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                  softWrap: true,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: hasReport
                    ? onSaveRequest
                    : null,
                  icon: Icon(
                    Icons.save_as_outlined,
                    size: 24,
                  ),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // 2. Main Stats Row (Count + Chart + Activity)
        // This replaces the old 3-card row and the bottom row
        TopStatsRow(viewModel: viewModel),
        
        const SizedBox(height: 24),
        
        // 3. Strategic Priorities (Overall Top 3)
        if (hasReport) ...[
          Text(
            "Strategic Priorities", 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 16),
          StrategicPrioritiesSection(reportData: viewModel.fullReport!),
          const SizedBox(height: 24),
        
          // 4. Campus Breakdown
          Text(
            "Campus Analysis", 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 16),
          GroupAnalysisSection(
            dataList: viewModel.fullReport!['Group_Mean_Plans_Campus'] as List? ?? [],
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
            dataList: viewModel.fullReport!['Group_Mean_Plans_Office_College'] as List? ?? [],
            icon: Icons.business,
          ),
          const SizedBox(height: 24),
        
          // Gemini Insights
          Text(
            "Gemini Insights", 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 16),
          GeminiInsightsCard(insights: viewModel.geminiInsights),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}