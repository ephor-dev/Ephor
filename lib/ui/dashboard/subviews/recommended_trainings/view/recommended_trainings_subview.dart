import 'package:ephor/ui/dashboard/subviews/recommended_trainings/view_model/recommended_trainings_viewmodel.dart';
import 'package:flutter/material.dart';

const Color _panelIconColor = Color(0xFFAC312B);

class RecommendedTrainingsSubView extends StatelessWidget {
  final RecommendedTrainingsViewModel viewModel;
  const RecommendedTrainingsSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text('Recommended Trainings Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}