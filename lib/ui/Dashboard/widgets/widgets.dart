import 'package:flutter/material.dart';

// 1. CONVERT TO STATEFUL WIDGET
class Widgets extends StatefulWidget {
  const Widgets({super.key});

  @override
  State<Widgets> createState() => _WidgetsState();
}

class _WidgetsState extends State<Widgets> {
  // 2. MOVE MENU ITEMS LIST INTO THE STATE
  // This list can now be changed and "remembered".
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.description_outlined, 'selected': true},
    {'title': 'Upcoming Schedules', 'icon': Icons.schedule_outlined, 'selected': false},
    {'title': 'Finished Assessments', 'icon': Icons.check_box_outlined, 'selected': false},
    {'title': 'Finished Trainings', 'icon': Icons.check_outlined, 'selected': false},
    {'title': 'Recommended Trainings', 'icon': Icons.wb_sunny_outlined, 'selected': false},
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
    
    // TODO: Add navigation logic here based on the 'index'
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
