import 'package:ephor/ui/dashboard/subviews/overview/widgets/group_stat_card.dart';
import 'package:flutter/material.dart';

class GroupAnalysisSection extends StatelessWidget {
  final List<dynamic> dataList;
  final IconData icon;

  const GroupAnalysisSection({super.key, required this.dataList, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) return const Text("No group data available.");

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1100 ? 3 : (constraints.maxWidth > 700 ? 2 : 1);
        double width = (constraints.maxWidth - ((crossAxisCount - 1) * 16)) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: dataList.map((item) {
            return SizedBox(
              width: width,
              child: GroupStatCard(
                groupName: item['Group_Name'].toString(),
                rating: item['Overall_Group_Rating'],
                primaryFocus: item['Primary_Focus_1'],
                secondaryFocus: item['Secondary_Focus_2'],
                icon: icon,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}