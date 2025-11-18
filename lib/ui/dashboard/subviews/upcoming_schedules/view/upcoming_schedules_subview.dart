import 'package:ephor/ui/dashboard/subviews/upcoming_schedules/view_model/upcoming_schedules_viewmodel.dart';
import 'package:flutter/material.dart';

const Color _panelIconColor = Color(0xFFAC312B);

class UpcomingSchedulesSubView extends StatelessWidget {
  final UpcomingSchedulesViewModel viewModel;
  const UpcomingSchedulesSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text('Upcoming Schedules Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}