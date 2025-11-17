import 'package:ephor/ui/dashboard/subviews/dark_mode/view_model/dark_mode_viewmodel.dart';
import 'package:flutter/material.dart';

class DarkModeToggleSubView extends StatelessWidget {
  final DarkModeToggleViewModel viewModel;
  const DarkModeToggleSubView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dark_mode_outlined, size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text('Dark Mode Toggle Subview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}