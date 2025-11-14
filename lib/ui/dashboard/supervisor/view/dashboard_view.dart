import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/dashboard/supervisor/view_model/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardView extends StatefulWidget {
  final DashboardViewModel viewModel;
  const DashboardView({super.key, required this.viewModel});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.description_outlined, 'selected': true},
    {'title': 'Upcoming Schedules', 'icon': Icons.schedule_outlined, 'selected': false},
    {'title': 'Finished Assessments', 'icon': Icons.check_box_outlined, 'selected': false},
    {'title': 'Finished Trainings', 'icon': Icons.check_outlined, 'selected': false},
    {'title': 'Recommended Trainings', 'icon': Icons.wb_sunny_outlined, 'selected': false},
    {'title': 'Toggle Dark Mode', 'icon': Icons.dark_mode_outlined, 'selected': false},
  ];

  final List<Widget> _screens = [
    const OverviewScreen(), // Index 0
    const UpcomingSchedulesScreen(), // Index 1
    const FinishedAssessmentsScreen(), // Index 2
    const FinishedTrainingsScreen(), // Index 3
    const RecommendedTrainingsScreen(), // Index 4
    const DarkModeToggleScreen(), // Index 5 - A placeholder screen
  ];

  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.logout.removeListener(_onResult);
    widget.viewModel.logout.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onResult);
    super.dispose();
  }

  void _onSelectItem(int index) {
    setState(() {
      for (int i = 0; i < menuItems.length; i++) {
        menuItems[i]['selected'] = false;
      }
      menuItems[index]['selected'] = true;

      _selectedIndex = index;
    });
    
    // Close the drawer
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${menuItems[index]['title']} Panel'),
        duration: const Duration(milliseconds: 500), 
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper function to build each menu item
  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap, // Changed to a simple callback
  }) {
    // Gradient for the selected state (Overview)
    final BoxDecoration decoration = isSelected
        ? BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            gradient: LinearGradient(
              colors: [const Color(0xFFE0B0A4).withAlpha(204), const Color(0xFFDE3535).withAlpha(204)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          )
        : const BoxDecoration();

    return Container(
      decoration: decoration,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
          size: 25,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.normal : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showInfoPlaceholder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info/About'),
          content: const Text('This section will provide information about the app or an "About Us" page.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications functionality coming soon! No new alerts.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // Call the ViewModel's logout function
    widget.viewModel.logout.execute();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Navigate to the login screen after logout.
  }

  void _handleEditProfile(BuildContext context) {
    // Call the ViewModel's editProfile placeholder function
    widget.viewModel.editProfile();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to Edit Profile...'),
        duration: Duration(seconds: 1),
      ),
    );
    // TODO: Implement navigation to the user profile editing screen.
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFAC312B);

    Scaffold mainChild = Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        width: 300, 
        backgroundColor: Colors.white, 
        child: Column(
          children: [
            // Custom Drawer Header
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false, 
                title: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
                      onPressed: () => Navigator.pop(context), // Closes the drawer
                    ),
                    const SizedBox(width: 15.0), 
                    Image.asset('assets/ephor_logo.jpg', height: 30, width: 30),
                    const SizedBox(width: 8.0),
                    const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),
                  ],
                ),
              ),
            ),

            // Navigation List Items
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0), 
                  child: _buildDrawerItem(
                    title: item['title'],
                    icon: item['icon'],
                    isSelected: item['selected'],
                    onTap: () => _onSelectItem(index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // --- END DRAWER ---

      // --- APP BAR (Top Navigation) ---
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 1.0, 
        automaticallyImplyLeading: false, 

        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 25), 
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              }, 
            ),
            // Spacing
            const SizedBox(width: 15.0), 

            Row(
              children: [
                Image.asset('assets/ephor_logo.jpg', height: 32, width: 32),
                const SizedBox(width: 8.0),
                const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),
              ],
            ),
            const SizedBox(width: 48.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0)),
                  ),
                  cursorColor: primaryRed, 
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 48.0),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.info_outline, color: Colors.black, size: 25), onPressed: _showInfoPlaceholder),
                IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black, size: 25), onPressed: _showNotificationsPlaceholder),
                const SizedBox(width: 15.0), 

                // User Profile/Avatar Icon
                PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  color: const Color(0xFFF7F7F7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  // Avatar button
                  child: ClipOval(child: CircleAvatar(radius: 15, backgroundColor: primaryRed, child: const Icon(Icons.person, color: Colors.white, size: 20),),),
                  
                  // Menu Items 
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // 1. User Header (Uses ViewModel data)
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 20, backgroundColor: primaryRed.withAlpha(204), child: const Icon(Icons.person, color: Colors.white)),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Accessing data from the ViewModel (userProfile object)
                                  Text("Username", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("Email", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 15),
                        ],
                      ),
                    ),
                    
                    // 2. Edit Profile
                    const PopupMenuItem<String>(
                      value: 'edit_profile',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Edit Profile'),
                        ],
                      ),
                    ),
                    
                    // 3. Logout
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  // Calling the corresponding handler which, in turn, calls the ViewModel
                  onSelected: (String result) {
                    if (result == 'edit_profile') {
                      _handleEditProfile(context);
                    } else if (result == 'logout') {
                      _handleLogout(context);
                    }
                  },
                ),
                const SizedBox(width: 8.0), 
              ],
            ),
          ],
        ),
      ),
      
      // --- BODY CONTENT ---
      body: _screens[_selectedIndex],
    );

    return ListenableBuilder(
      listenable: widget.viewModel.logout, 
      builder: (context, _) {
        return mainChild;
      }
    );
  }

  void _onResult() {
    if (widget.viewModel.logout.completed) {
      widget.viewModel.logout.clearResult();
      context.go(Routes.login);
    }

    if (widget.viewModel.logout.error) {
      widget.viewModel.logout.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error while logging out"),
          action: SnackBarAction(
            label: "Try Again",
            onPressed: () => widget.viewModel.logout.execute(),
          ),
        ),
      );
    }
  }
}


const Color _panelIconColor = Color(0xFFAC312B); // Primary Red color used for icons

// Screen 1: Overview
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text(
            'Overview Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Your main dashboard metrics and summaries will be here.'),
        ],
      ),
    );
  }
}

// Screen 2: Upcoming Schedules
class UpcomingSchedulesScreen extends StatelessWidget {
  const UpcomingSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text(
            'Upcoming Schedules Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Manage all your scheduled activities.'),
        ],
      ),
    );
  }
}

// Screen 3: Finished Assessments
class FinishedAssessmentsScreen extends StatelessWidget {
  const FinishedAssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text(
            'Finished Assessments Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Review your scores and assessment history.'),
        ],
      ),
    );
  }
}

// Screen 4: Finished Trainings
class FinishedTrainingsScreen extends StatelessWidget {
  const FinishedTrainingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text(
            'Finished Trainings Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('View your completed training courses and certificates.'),
        ],
      ),
    );
  }
}

// Screen 5: Recommended Trainings
class RecommendedTrainingsScreen extends StatelessWidget {
  const RecommendedTrainingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 80, color: _panelIconColor),
          SizedBox(height: 16),
          Text(
            'Recommended Trainings Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('Suggestions tailored to your development needs.'),
        ],
      ),
    );
  }
}

// Screen 6: Dark Mode Toggle Placeholder
class DarkModeToggleScreen extends StatelessWidget {
  const DarkModeToggleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dark_mode_outlined, size: 80, color: Colors.black54),
          SizedBox(height: 16),
          Text(
            'Dark Mode Toggle Panel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text('This screen confirms dark mode selection logic.'),
        ],
      ),
    );
  }
}