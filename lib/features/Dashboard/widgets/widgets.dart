import 'package:flutter/material.dart';
import '../../hrmo/add_personnel_view.dart';
import '../../hrmo/remove_personnel_view.dart';

// 1. CONVERT TO STATEFUL WIDGET
class Widgets extends StatefulWidget {
  const Widgets({super.key});

  @override
  State<Widgets> createState() => _WidgetsState();
}

class _WidgetsState extends State<Widgets> {
  // 2. HRMO MENU ITEMS LIST
  // This list contains HRMO-specific navigation items.
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.dashboard_outlined, 'selected': true},
    {'title': 'Add/Remove Personnel', 'icon': Icons.person_add_outlined, 'selected': false},
    {'title': 'CATNA Results', 'icon': Icons.assessment_outlined, 'selected': false},
    {'title': 'Impact Assessment Results', 'icon': Icons.trending_up_outlined, 'selected': false},
    {'title': 'Trainings', 'icon': Icons.school_outlined, 'selected': false},
    {'title': 'Create/Edit Forms', 'icon': Icons.edit_note_outlined, 'selected': false},
    {'title': 'Toggle Dark Mode', 'icon': Icons.dark_mode_outlined, 'selected': false},
  ];

  // 3. CREATE THE FUNCTION TO HANDLE CLICKS
  void _onSelectItem(int index) {
    // setState() tells Flutter to rebuild the widget with the new changes
    setState(() {
      // Loop through all items and set 'selected' to false
      for (int i = 0; i < menuItems.length; i++) {
        menuItems[i]['selected'] = false;
      }
      // Set the tapped item's 'selected' to true
      menuItems[index]['selected'] = true;
    });
    
    // Close the drawer
    Navigator.pop(context);
    
    // Navigation logic for HRMO features
    switch (index) {
      case 0: // Overview
        // Already on Overview page
        break;
      case 1: // Add/Remove Personnel
        // Show a dialog to choose between Add or Remove
        _showAddRemoveDialog(context);
        break;
      case 2: // CATNA Results
        // TODO: Navigate to CATNA Results
        break;
      case 3: // Impact Assessment Results
        // TODO: Navigate to Impact Assessment Results
        break;
      case 4: // Trainings
        // TODO: Navigate to Trainings
        break;
      case 5: // Create/Edit Forms
        // TODO: Navigate to Create/Edit Forms
        break;
      case 6: // Toggle Dark Mode
        // TODO: Add dark mode toggle if needed
        break;
    }
  }

  // We need the key to be part of the State, not a local variable in build()
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
          // Simplified as per your request (text is always black)
          color: Colors.black,
          size: 25,
        ),
        title: Text(
          title,
          style: TextStyle(
            // Simplified as per your request (text is always black)
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.normal : FontWeight.normal,
          ),
        ),
        onTap: onTap, // Use the callback passed from the builder
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFAC312B); // Hex: AC312B

    return Scaffold(
      key: _scaffoldKey, // Assign the state's key to the Scaffold
      backgroundColor: Colors.white, // Ensure white background for landing page

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
                    // UPDATED: Replaced static Icon with IconButton to close the Drawer
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
                      onPressed: () => Navigator.pop(context), // Closes the drawer
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
                    // 4. UPDATE ONTAP TO CALL THE NEW FUNCTION
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
            // 1. Hamburger Menu Icon (UPDATED to open the drawer)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 25), 
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer(); // Open the Drawer on press
              }, 
            ),
            // Spacing
            const SizedBox(width: 15.0), 
            
            // 2. Logo and App Name (EPHOR)
            Row(
              children: [
                Image.asset('assets/images/logo.png', height: 30, width: 30),
                const SizedBox(width: 8.0),
                const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),
              ],
            ),
            
            // Spacing
            const SizedBox(width: 48.0),

            // 3. Search Bar 
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

            // Spacing
            const SizedBox(width: 48.0),

            // 4. Right-Side Icons 
            Row(
              children: [
                IconButton(icon: const Icon(Icons.info_outline, color: Colors.black, size: 25), onPressed: () { /* TODO */ }),
                IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black, size: 25), onPressed: () { /* TODO */ }),
                const SizedBox(width: 15.0), 

                // User Profile/Avatar Icon
                ClipOval( 
                  child: Material( 
                    color: Colors.transparent,
                    child: InkWell( 
                      onTap: () { /* TODO */ },
                      child: CircleAvatar(
                        radius: 15, 
                        backgroundColor: primaryRed, 
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), 
              ],
            ),
          ],
        ),
      ),
      
      // --- BODY CONTENT (HRMO Dashboard Overview) ---
      body: const Padding(
        padding: EdgeInsets.only(top: 24.0, left: 32.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Add HRMO Dashboard Overview content here
            // - Statistics cards
            // - Quick actions
            // - Recent activities
            // - Charts and visualizations
          ],
        ),
      ),
    );
  }

  /// Show dialog to choose between Add or Remove Personnel
  void _showAddRemoveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54, // Semi-transparent gray background
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 24,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Enhanced Header
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Personnel Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 22,
                            ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              // Content with Card-based tiles
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Add Personnel Card
                    _PersonnelActionCard(
                      icon: Icons.person_add,
                      iconColor: const Color(0xFFFFB47B), // Peach/orange accent
                      title: 'Add Personnel',
                      subtitle: 'Add a new personnel to the system',
                      onTap: () {
                        Navigator.of(context).pop();
                        AddPersonnelView.show(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Remove Personnel Card
                    _PersonnelActionCard(
                      icon: Icons.person_remove,
                      iconColor: Colors.red.shade600, // Red accent
                      title: 'Remove Personnel',
                      subtitle: 'View and remove existing personnel',
                      onTap: () {
                        Navigator.of(context).pop();
                        RemovePersonnelView.show(context);
                      },
                    ),
                  ],
                ),
              ),
              // Cancel Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom card widget for personnel action tiles
class _PersonnelActionCard extends StatelessWidget {
  const _PersonnelActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  // Icon with background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
