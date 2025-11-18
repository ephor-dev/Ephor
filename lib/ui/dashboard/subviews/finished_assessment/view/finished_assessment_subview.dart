import 'package:ephor/ui/dashboard/subviews/finished_assessment/view_model/finished_assessment_viewmodel.dart';
import 'package:flutter/material.dart';

const Color _panelIconColor = Color(0xFFAC312B);

class FinishedAssessmentsSubView extends StatelessWidget {
  final FinishedAssessmentsViewModel viewModel;
  const FinishedAssessmentsSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text('Finished Assessments Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}