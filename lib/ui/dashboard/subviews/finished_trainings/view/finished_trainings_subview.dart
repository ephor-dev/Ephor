import 'package:ephor/ui/dashboard/subviews/finished_trainings/view_model/finished_trainings_viewmodel.dart';
import 'package:flutter/material.dart';

const Color _panelIconColor = Color(0xFFAC312B);

class FinishedTrainingsSubView extends StatelessWidget {
  final FinishedTrainingsViewModel viewModel;
  const FinishedTrainingsSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text('Finished Trainings Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}