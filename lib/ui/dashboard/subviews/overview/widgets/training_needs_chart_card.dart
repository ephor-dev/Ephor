import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
import 'package:ephor/ui/dashboard/subviews/overview/widgets/legend_item.dart';
import 'package:flutter/material.dart';

class TrainingNeedsChartCard extends StatelessWidget {
  final OverviewViewModel viewModel;
  const TrainingNeedsChartCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    String percentageText = "0%";
    double chartValue = 0.0;
    
    // Dynamic Legend Data placeholders
    String rank1Label = "Priority 1";
    String rank2Label = "Priority 2";
    String rank3Label = "Priority 3";

    if (viewModel.fullReport != null) {
      final individuals = viewModel.fullReport!['Individual_Training_Plans'] as List? ?? [];
      final topNeeds = viewModel.fullReport!['Overall_Top_3_Needs'] as List? ?? [];

      if (individuals.isNotEmpty && topNeeds.isNotEmpty) {
        topNeeds.sort((a, b) => (a['Rank'] as int).compareTo(b['Rank'] as int));
        
        final topNeed = topNeeds.first;
        final topCode = topNeed['Focus_Area_Component'];
        final countMatching = individuals.where((i) => i['Lowest_Component'] == topCode).length;

        if (individuals.isNotEmpty) {
          chartValue = countMatching / individuals.length;
          percentageText = "${(chartValue * 100).toStringAsFixed(0)}%";
        }

        rank1Label = "${topNeeds[0]['Focus_Area_Component']} - Rank 1";
        if (topNeeds.length > 1) rank2Label = "${topNeeds[1]['Focus_Area_Component']} - Rank 2";
        if (topNeeds.length > 2) rank3Label = "${topNeeds[2]['Focus_Area_Component']} - Rank 3";
      }
    }

    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Card(
        color: Theme.brightnessOf(context) == Brightness.light
          ? Colors.white
          : Theme.of(context).colorScheme.surfaceContainerHighest,
        shadowColor: Theme.of(context).colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Needs Distribution",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18, fontWeight: FontWeight.bold
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: chartValue == 0 ? 0.05 : chartValue,
                              strokeWidth: 25,
                              backgroundColor: Theme.brightnessOf(context) == Brightness.light
                                ? const Color.fromARGB(31, 114, 114, 114)
                                : Theme.of(context).colorScheme.outlineVariant,
                              color: Theme.brightnessOf(context) == Brightness.light 
                                ? const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0)
                                : Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                          Text(
                            percentageText, 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface, 
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LegendItem(color: const Color.from(alpha: 0.867, red: 139, green: 0, blue: 0), label: rank1Label),
                          LegendItem(color: const Color.fromARGB(221, 0, 0, 0), label: rank2Label),
                          LegendItem(color: const Color.fromARGB(221, 54, 54, 54), label: rank3Label),
                          const LegendItem(color: Color.fromARGB(221, 88, 88, 88), label: "Others"),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}