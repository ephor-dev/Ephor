import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:ephor/ui/Dashboard/view_model/view_models.dart'; 

class Widgets extends StatefulWidget {
  const Widgets({super.key});

  @override
  State<Widgets> createState() => _WidgetsState();
}

class _WidgetsState extends State<Widgets> {
  // REMOVED: Hardcoded user data is now managed by UserProfileViewModel.
  // final String _currentUserName = "John Doe";
  // final String _currentUserEmail = "john.doe@ephor.com";
  
  // 1. STATE VARIABLE: Tracks the index of the currently selected screen.
  int _selectedIndex = 0; 
  
  // 2. DEFINE THE SCREENS/WIDGETS FOR EACH MENU ITEM
  final List<Widget> _screens = [
    const OverviewScreen(), // Index 0
    const UpcomingSchedulesScreen(), // Index 1
    const FinishedAssessmentsScreen(), // Index 2
    const FinishedTrainingsScreen(), // Index 3
    const RecommendedTrainingsScreen(), // Index 4
    const DarkModeToggleScreen(), // Index 5 - A placeholder screen
  ];

  // 3. CREATE THE FUNCTION TO HANDLE DRAWER CLICKS (UPDATED)
  void _onSelectItem(int index) {
    setState(() {
      // Update menu item selection state
      for (int i = 0; i < menuItems.length; i++) {
        menuItems[i]['selected'] = false;
      }
      menuItems[index]['selected'] = true;
      
      // Update the selected index to switch the body content
      _selectedIndex = index; 
    });
    
    // Close the drawer
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
    
    // SnackBar for demonstration 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${menuItems[index]['title']} Panel'),
        duration: const Duration(milliseconds: 500), 
      ),
    );
  }
  
  // Key for accessing Scaffold state (e.g., opening drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.description_outlined, 'selected': true},
    {'title': 'Upcoming Schedules', 'icon': Icons.schedule_outlined, 'selected': false},
    {'title': 'Finished Assessments', 'icon': Icons.check_box_outlined, 'selected': false},
    {'title': 'Finished Trainings', 'icon': Icons.check_outlined, 'selected': false},
    {'title': 'Recommended Trainings', 'icon': Icons.wb_sunny_outlined, 'selected': false},
    {'title': 'Toggle Dark Mode', 'icon': Icons.dark_mode_outlined, 'selected': false},
  ];

  // Helper function to build each menu item
  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Gradient for the selected state
    final BoxDecoration decoration = isSelected
        ? BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            gradient: LinearGradient(
              colors: [const Color(0xFFE0B0A4).withOpacity(0.8), const Color(0xFFDE3535).withOpacity(0.8)],
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

  // Placeholder for Info/About Icon
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

  // Placeholder for Notifications Icon
  void _showNotificationsPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications functionality coming soon! No new alerts.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Function for the Logout action (UPDATED)
  void _handleLogout(BuildContext context) {
    // Call the ViewModel's logout function
    Provider.of<UserProfileViewModel>(context, listen: false).logout();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Navigate to the login screen after logout.
  }

  // Function for the Edit Profile action (UPDATED)
  void _handleEditProfile(BuildContext context) {
    // Call the ViewModel's editProfile placeholder function
    Provider.of<UserProfileViewModel>(context, listen: false).editProfile();

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
    const Color primaryRed = Color(0xFFAC312B); // Hex: AC312B
    // const Color _panelIconColor = Color(0xFFAC312B); // Not needed here

    // 💡 Consumer Widget: Listens for changes in UserProfileViewModel 
    // and rebuilds the parts that need the user data (like the AppBar).
    return Consumer<UserProfileViewModel>(
      builder: (context, userProfile, child) {
        
        // Simple check: If user is logged out, show a basic message 
        // (This is where you'd navigate to a LoginScreen in a real app)
        if (!userProfile.isLoggedIn) {
          return const Scaffold(
            body: Center(
              child: Text(
                "User is logged out. Please restart the app or navigate to LoginScreen.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey, 

          // --- DRAWER (The Sliding Menu) ---
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
                          onPressed: () => Navigator.pop(context), 
                        ),
                        const SizedBox(width: 15.0), 
                        Image.asset('assets/images/logo.png', height: 30, width: 30),
                        const SizedBox(width: 8.0),
                        const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),
                      ],
                    ),
                  ),
                ),

                // Navigation List Items
                Expanded( 
                  child: ListView.builder(
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
                          onTap: () => _onSelectItem(index), // Calls the function that updates the body
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- APP BAR (Top Navigation) ---
          appBar: AppBar(
            backgroundColor: Colors.white, 
            elevation: 1.0, 
            automaticallyImplyLeading: false, 

            title: Row(
              children: [
                // Hamburger Menu Icon
                IconButton(icon: const Icon(Icons.menu, color: Colors.black, size: 25), onPressed: () { _scaffoldKey.currentState?.openDrawer(); }),
                const SizedBox(width: 15.0), 
                // Logo and App Name
                Row(children: [Image.asset('assets/images/logo.png', height: 30, width: 30), const SizedBox(width: 8.0), const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),]),
                const SizedBox(width: 48.0),
                // Search Bar 
                Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: TextField(decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade100, hintText: 'Search', hintStyle: TextStyle(color: Colors.grey.shade600), prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0)),), cursorColor: primaryRed, style: const TextStyle(fontSize: 16),))),
                const SizedBox(width: 48.0),
                // Right-Side Icons 
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.info_outline, color: Colors.black, size: 25), onPressed: _showInfoPlaceholder),
                    IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black, size: 25), onPressed: _showNotificationsPlaceholder),
                    const SizedBox(width: 15.0), 
                    
                    // User Profile/Avatar Dropdown (USES VIEW MODEL)
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
                                  CircleAvatar(radius: 20, backgroundColor: primaryRed.withOpacity(0.8), child: const Icon(Icons.person, color: Colors.white)),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Accessing data from the ViewModel (userProfile object)
                                      Text(userProfile.currentUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      Text(userProfile.currentUserEmail, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
          
          // --- BODY CONTENT (Dashboard Panel) ---
          body: _screens[_selectedIndex],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// DASHBOARD PANEL WIDGETS (Unchanged)
// ----------------------------------------------------------------------
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