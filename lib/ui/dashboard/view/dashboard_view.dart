import 'package:cached_network_image/cached_network_image.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ephor/utils/responsiveness.dart';

class DashboardView extends StatefulWidget {
  final DashboardViewModel viewModel;
  final Widget child;
  const DashboardView({super.key, required this.viewModel, required this.child});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  static const Color _primaryRed = Color(0xFFAC312B);
  bool _isPasswordVisible = false;
  final TextEditingController _passwordController = TextEditingController();

  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Overview', 'icon': Icons.description_outlined, 'selected': true, 'path': Routes.dashboardOverview},
    {'title': 'Employee List', 'icon': Icons.list, 'selected': false, 'path': Routes.dashboardEmployeeList},
    {'title': 'Upcoming Schedules', 'icon': Icons.schedule_outlined, 'selected': false, 'path': Routes.dashboardSchedules},
    {'title': 'Finished Assessments', 'icon': Icons.check_box_outlined, 'selected': false, 'path': Routes.dashboardAssessments},
    {'title': 'Finished Trainings', 'icon': Icons.check_outlined, 'selected': false, 'path': Routes.dashboardFinishedTrainings},
    {'title': 'Recommended Trainings', 'icon': Icons.wb_sunny_outlined, 'selected': false, 'path': Routes.dashboardRecommendedTrainings},
  ];

  int _getSelectedIndex() {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
  
    final index = menuItems.indexWhere((item) {
      final path = item['path'];
      return path != null && location.contains(path);
    });

    return index != -1 ? index : 0;
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onResult);
    widget.viewModel.checkPassword.addListener(_onPasswordChecked);
  }

  @override
  void didUpdateWidget(covariant DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.logout != widget.viewModel.logout) {
      oldWidget.viewModel.logout.removeListener(_onResult);
      widget.viewModel.logout.addListener(_onResult);
    }

    if (oldWidget.viewModel.checkPassword != widget.viewModel.checkPassword) {
      oldWidget.viewModel.logout.removeListener(_onPasswordChecked);
      widget.viewModel.checkPassword.addListener(_onPasswordChecked);
    }
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onResult);
    widget.viewModel.checkPassword.removeListener(_onPasswordChecked);
    super.dispose();
  }

  void _onSelectItem(String pathSegment) {
    final fullPath = '${Routes.dashboard}/$pathSegment';
    context.go(fullPath); 
    
    // Always close the drawer after selection
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $pathSegment Panel'),
        duration: const Duration(milliseconds: 500), 
      ),
    );
  }

  // Helper function to build each menu item
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Helper to build the core menu list (used inside the Drawer)
  Widget _buildMenuList(int selectedIndex) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0, left: 0, right: 10),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0), 
          child: _buildMenuItem(
            title: item['title'],
            icon: item['icon'],
            isSelected: index == selectedIndex,
            onTap: () => _onSelectItem(item['path']),
          ),
        );
      },
    );
  }

  // Helper to build the Drawer content
  Widget _buildDrawer() {
    final selectedIndex = _getSelectedIndex();
    return Drawer(
      // Set max drawer width, but allow it to shrink on smaller screens
      width: 300, 
      backgroundColor: Colors.white, 
      child: Column(
        children: [
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
          _buildMenuList(selectedIndex),
        ],
      ),
    );
  }

  // Placeholder functions
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

  void _handleEditInfo(BuildContext context) {
    context.pop();

    showDialog(
      context: context,
      builder: (BuildContext context) {

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm it is You'),
              constraints: BoxConstraints.tight(Size(540, 240)),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enter your password to proceed to update your user information'),
                  const SizedBox(height: 16,),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    widget.viewModel.checkPassword.execute(_passwordController.text);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    widget.viewModel.logout.execute();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          constraints: BoxConstraints.tight(Size(540, 350)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This section will provide you options to modify what you use in Ephor.'),
              SizedBox.fromSize(size: Size.fromHeight(16),),
              Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text("Update your Information", style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Update your email, full name and/or image."),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {_handleEditInfo(context);},
                ),
              ),
              Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.password),
                  title: Text("Change your Password", style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Keep your account secured by changing password."),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    context.go(Routes.updatePassword);
                  },
                ),
              )
            ],
          ),
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

  void _onResult() {
    if (widget.viewModel.logout.completed) {
      widget.viewModel.logout.clearResult();
      context.go(Routes.login);
    }

    if (widget.viewModel.logout.error) {
      widget.viewModel.logout.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error while logging out"),
          action: SnackBarAction(
            label: "Try Again",
            onPressed: () => widget.viewModel.logout.execute(),
          ),
        ),
      );
    }
  }

  void _onPasswordChecked() {
    if (widget.viewModel.checkPassword.completed) {
      widget.viewModel.logout.clearResult();
      context.pop();
      context.go(Routes.getAddEmployeePath());
    }

    if (widget.viewModel.checkPassword.error) {
      widget.viewModel.checkPassword.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Enter your correct password to edit user information."),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar({required bool isMobile}) {
    return AppBar(
      backgroundColor: Colors.white, 
      elevation: 1.0, 
      automaticallyImplyLeading: false,
      title: ValueListenableBuilder<EmployeeModel?>(
        valueListenable: widget.viewModel.currentUser,
        builder: (context, currentUser, child) {
          final String? imageUrl = currentUser?.photoUrl;
          final String username = currentUser?.fullName ?? "Username";
          final String email = currentUser?.email ?? "Email";

          return Row(
            children: [
              // Menu button is always visible to open the drawer
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black, size: 25), 
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                }, 
              ),

              const SizedBox(width: 15.0), 
              
              // Logo and Title
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 32, width: 32),
                  const SizedBox(width: 8.0),
                  const Text('EPHOR', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18.0)),
                ],
              ),
              
              const SizedBox(width: 48.0),
              
              // Search Bar: Takes up available space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ConstrainedBox(
                    // Max width ensures search bar doesn't look too wide on huge screens
                    constraints: const BoxConstraints(maxWidth: 500), 
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
                      cursorColor: _primaryRed, 
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 48.0),
              
              // Action Buttons (Info, Notifications, Profile)
              Row(
                // Use responsive checks here if you wanted to hide some buttons on mobile
                children: [
                  // Use Responsive.isMobile to decide if to show or not
                  if (!isMobile || Responsive.isTablet(context))
                    IconButton(icon: const Icon(Icons.info_outline, color: Colors.black, size: 25), onPressed: _showInfoPlaceholder),
                  
                  IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black, size: 25), onPressed: _showNotificationsPlaceholder),
                  
                  const SizedBox(width: 15.0), 

                  // User Profile/Avatar Icon
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    color: const Color(0xFFF7F7F7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl ?? 'Error',
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Text(username[0]),
                      ),
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                          backgroundImage: imageProvider,
                          radius: 16,
                        );
                      },
                    ),
                    
                    // Menu Items 
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(email, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Divider(height: 15),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit_profile',
                        child: Row(children: [Icon(Icons.settings_outlined, color: Colors.black87), SizedBox(width: 8), Text('Edit Profile')]),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(children: [Icon(Icons.logout, color: Colors.black87), SizedBox(width: 8), Text('Logout')]),
                      ),
                    ],
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
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.logout, 
      builder: (context, _) {
        final isMobile = Responsive.isMobile(context);
        
        // Use a single Scaffold for all views.
        // The drawer width is flexible, and the body (widget.child) occupies the rest of the space responsively.
        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(isMobile: isMobile),
          drawer: _buildDrawer(), // Hidden drawer used for navigation
          body: widget.child, // The main content area is now fully expanded
        );
      }
    );
  }
}