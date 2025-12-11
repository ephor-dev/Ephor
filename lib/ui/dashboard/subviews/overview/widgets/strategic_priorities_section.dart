import 'package:ephor/ui/dashboard/subviews/overview/widgets/priority_card.dart';
import 'package:flutter/material.dart';

class StrategicPrioritiesSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  const StrategicPrioritiesSection({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final topNeeds = reportData['Overall_Top_3_Needs'] as List? ?? [];
    topNeeds.sort((a, b) => (a['Rank'] as int).compareTo(b['Rank'] as int));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: topNeeds.map((need) {
            final isLast = need == topNeeds.last;
            final card = Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: isMobile ? 16 : 0, 
                  right: (!isMobile && !isLast) ? 16 : 0
                ),
                child: PriorityCard(
                  rank: need['Rank'],
                  score: need['Mean_Score'],
                  code: need['Focus_Area_Component'],
                  description: need['Training_Recommendation'],
                ),
              ),
            );
            return card;
          }).toList(),
        );
      }
    );
  }
}