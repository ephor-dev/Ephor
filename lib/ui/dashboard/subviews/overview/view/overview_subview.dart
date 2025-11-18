import 'package:ephor/ui/dashboard/subviews/overview/view_model/overview_viewmodel.dart';
import 'package:flutter/material.dart';

const Color _panelIconColor = Color(0xFFAC312B);

class OverviewSubView extends StatelessWidget {
  final OverviewViewModel viewModel;
  const OverviewSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Note: The View now uses its own ViewModel
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text('Overview Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('This subview uses its own ViewModel for state management.'),
        ],
      ),
    );
  }
}