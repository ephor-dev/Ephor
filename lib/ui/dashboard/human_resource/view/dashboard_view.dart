import 'package:flutter/material.dart';

class HRDashboardView extends StatefulWidget {
  const HRDashboardView({super.key, required String viewModel});

  @override
  State<HRDashboardView> createState() => _HRDashboardViewState();
}

class _HRDashboardViewState extends State<HRDashboardView> {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.description_outlined, 'selected': true},
    {'title': 'Upcoming Schedules', 'icon': Icons.schedule_outlined, 'selected': false},
    {'title': 'Finished Assessments', 'icon': Icons.check_box_outlined, 'selected': false},
    {'title': 'Finished Trainings', 'icon': Icons.check_outlined, 'selected': false},
    {'title': 'Recommended Trainings', 'icon': Icons.wb_sunny_outlined, 'selected': false},
    {'title': 'Toggle Dark Mode', 'icon': Icons.dark_mode_outlined, 'selected': false},
  ];

  void _onSelectItem(int index) {
    setState(() {
      for (int i = 0; i < menuItems.length; i++) {
        menuItems[i]['selected'] = false;
      }
      menuItems[index]['selected'] = true;
    });
    
    // Close the drawer
    Navigator.pop(context);
    
    // TODO: Add navigation logic here based on the 'index'
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

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFAC312B);

    return Scaffold(
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
                Image.asset('assets/images/logo.png', height: 32, width: 32),
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
      
      // --- BODY CONTENT ---
      body: const Padding(
        padding: EdgeInsets.only(top: 24.0, left: 32.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REMOVED THE TEXT('Overview') AS IT IS INDICATED BY THE SELECTED DRAWER ITEM
          ],
        ),
      ),
    );
  }
}
