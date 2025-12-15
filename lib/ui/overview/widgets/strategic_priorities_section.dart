import 'package:ephor/ui/overview/widgets/priority_card.dart';
import 'package:flutter/material.dart';

class StrategicPrioritiesSection extends StatelessWidget {
  final Map<String, dynamic> reportData;
  const StrategicPrioritiesSection({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final topNeeds = reportData['Overall_Top_3_Needs'] as List? ?? [];

    // FIX 1: Safe sorting. We treat Rank as 'num' so it doesn't crash if it's 1.0
    topNeeds.sort((a, b) {
      final rankA = (a['Rank'] as num).toInt();
      final rankB = (b['Rank'] as num).toInt();
      return rankA.compareTo(rankB);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;
        
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: topNeeds.map((need) {
            final isLast = need == topNeeds.last;
            
            return Expanded(
              flex: isMobile ? 0 : 1,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: isMobile ? 16 : 0, 
                  right: (!isMobile && !isLast) ? 16 : 0
                ),
                child: PriorityCard(
                  // FIX 2: Safe casting using 'num'. 
                  // It accepts 1 or 1.0 and forces it to become an integer (1).
                  rank: (need['Rank'] as num).toInt(),
                  
                  // FIX 3: Same for score. If 'Mean_Score' is 4, it becomes 4.0. 
                  // (Assuming PriorityCard expects a double for score. 
                  // If it expects int, change to .toInt())
                  score: (need['Mean_Score'] as num).toDouble(),
                  
                  code: need['Focus_Area_Component'],
                  description: need['Training_Recommendation'],
                ),
              ),
            );
          }).toList(),
        );
      }
    );
  }
}