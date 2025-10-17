import 'package:ephor/data/models/app_user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard_view_model.dart';
import '../../core/utils/responsive.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: Consumer<DashboardViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => viewModel.signOut(),
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.errorMessage != null) {
                  return Center(child: Text(viewModel.errorMessage!));
                }
                return Responsive(
                  mobile: _buildMobileLayout(viewModel.user),
                  desktop: _buildDesktopLayout(viewModel.user),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(AppUser? user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_pin, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          Text('Welcome, ${user?.name ?? 'User'}!',
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Code: ${user?.employeeCode ?? ''}',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text('Email: ${user?.email ?? ''}',
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AppUser? user) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: 0,
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.settings), label: Text('Settings')),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildMobileLayout(user)),
      ],
    );
  }
}