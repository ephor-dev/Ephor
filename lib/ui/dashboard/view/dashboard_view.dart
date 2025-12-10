import 'package:cached_network_image/cached_network_image.dart';
import 'package:ephor/domain/enums/employee_role.dart';
import 'package:ephor/domain/models/employee/employee.dart';
import 'package:ephor/routing/routes.dart';
import 'package:ephor/ui/core/ui/confirm_identity_dialog/confirm_identity_dialog.dart';
import 'package:ephor/ui/core/ui/dashboard_menu_item/dashboard_menu_item.dart';
import 'package:ephor/ui/core/ui/edit_profile_dialog/edit_profile_dialog.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  bool _shouldShowSearch(String location) {
    return location.contains(Routes.dashboardEmployeeList);
  }

  // 2. LOGIC FIX: Helper to get index without modifying state
  int _getSelectedIndex(List<Map<String, dynamic>> currentItems) {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    
    // Use the passed list, not the getter
    final index = currentItems.indexWhere((item) {
      final path = item['path'];
      return path != null && location.contains(path);
    });

    return index != -1 ? index : 0;
  }

  List<Map<String, dynamic>> get menuItems {
    final EmployeeRole? role = widget.viewModel.currentUser.value?.role;
    final List<Map<String, dynamic>> allItems = [
      {
        'title': 'Overview',
        'icon': Icons.description_outlined,
        'selected': true, // Note: You might want to make this dynamic based on current route
        'path': Routes.dashboardOverview
      },
      {
        'title': 'Employee Management',
        'icon': Icons.list,
        'selected': false,
        'path': Routes.dashboardEmployeeList
      },
      {
        'title': 'Forms Management',
        'icon': Icons.assessment_outlined,
        'selected': false,
        'path': Routes.dashboardMyForms
      },
      {
        'title': 'Fill CATNA',
        'icon': Icons.assessment_outlined,
        'selected': false,
        'path': Routes.dashboardCatnaForms
      },
      {
        'title': 'Fill IA',
        'icon': Icons.assessment_outlined,
        'selected': false,
        'path': Routes.dashboardIAForm
      },
    ];

    // 3. Filter based on Role
    return allItems.where((item) {
      final String path = item['path'];

      // HIDE 'Forms Management' from Supervisors
      if (role == EmployeeRole.supervisor && path == Routes.dashboardMyForms) {
        return false;
      }

      // HIDE 'Fill CATNA' and 'Fill IA' from HR
      if (role == EmployeeRole.humanResource &&
          (path == Routes.dashboardCatnaForms || path == Routes.dashboardIAForm)) {
        return false;
      }

      // Show everything else
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onResult);
    widget.viewModel.checkPassword.addListener(_onPasswordChecked);
    widget.viewModel.setDarkMode.addListener(_onDarkModePrefsChanged);
    _searchController.addListener(_updateListFromSearch);
  }

  @override
  void didUpdateWidget(covariant DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.logout != widget.viewModel.logout) {
      oldWidget.viewModel.logout.removeListener(_onResult);
      widget.viewModel.logout.addListener(_onResult);
    }

    if (oldWidget.viewModel.checkPassword != widget.viewModel.checkPassword) {
      oldWidget.viewModel.checkPassword.removeListener(_onPasswordChecked);
      widget.viewModel.checkPassword.addListener(_onPasswordChecked);
    }

    if (oldWidget.viewModel.setDarkMode != widget.viewModel.setDarkMode) {
      oldWidget.viewModel.setDarkMode.removeListener(_onDarkModePrefsChanged);
      widget.viewModel.setDarkMode.addListener(_onDarkModePrefsChanged);
    }
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onResult);
    widget.viewModel.checkPassword.removeListener(_onPasswordChecked);
    widget.viewModel.setDarkMode.removeListener(_onDarkModePrefsChanged);
    _searchController.dispose();
    _searchController.removeListener(_updateListFromSearch);
    super.dispose();
  }

  void _onSelectItem(String pathSegment) {
    final fullPath = '${Routes.dashboard}/$pathSegment';
    context.go(fullPath); 
    
    // Always close the drawer after selection
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  void _updateListFromSearch() {
    widget.viewModel.setEmployeeManagementSearchKeyword.execute(_searchController.text);
  }

  // Helper to build the core menu list (used inside the Drawer)
  Widget _buildMenuList(List<Map<String, dynamic>> currentItems, int selectedIndex) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0, left: 0, right: 10),
      itemCount: currentItems.length,
      itemBuilder: (context, index) {
        final item = currentItems[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DashboardMenuItem(
            title: item['title'], 
            icon: item['icon'], 
            isSelected: index == selectedIndex, 
            onTap: () => _onSelectItem(item['path'])
          ),
        );
      },
    );
  }

  // Helper to build the Drawer content
  Widget _buildDrawer() {
    final currentMenuItems = menuItems;
    final selectedIndex = _getSelectedIndex(currentMenuItems);
    return Drawer(
      // Set max drawer width, but allow it to shrink on smaller screens
      width: 300, 
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest, 
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              elevation: 0,
              automaticallyImplyLeading: false, 
              title: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back, 
                      color: Theme.of(context).colorScheme.onSurface, 
                      size: 25
                    ),
                    onPressed: () => Navigator.pop(context), // Closes the drawer
                  ),
                  const SizedBox(width: 15.0), 
                  Image.asset('assets/images/logo.png', height: 32, width: 32),
                  const SizedBox(width: 8.0),
                  Text(
                    'EPHOR', 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(222), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18.0
                    )
                  ),
                ],
              ),
            ),
          ),
          _buildMenuList(currentMenuItems,selectedIndex),
        ],
      ),
    );
  }

  // Placeholder functions
  void _showInfoPlaceholder() {
    showAboutDialog(
      context: context,
      applicationName: 'Ephor',
      applicationVersion: 'v. 0.1.0',
      applicationIcon: Image.asset(
        'assets/images/logo.png',
        width: 96,
        height: 96,
      ),
      applicationLegalese: "© Copyright Ephor-Dev 2025",
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

  void _handleEditUserInfo(BuildContext context) {
    context.pop();
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return ConfirmIdentityDialog(viewModel: widget.viewModel);
      }
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
        return EditProfileDialog(
          updateInfoCallback: () => {
            _handleEditUserInfo(context)
          }
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
      context.goNamed(
        'edit_employee',
        queryParameters: {
          'fromUser': 'true',
          'code': widget.viewModel.currentUser.value?.employeeCode
        } 
      );
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

  void _onDarkModePrefsChanged() {
    if (widget.viewModel.setDarkMode.completed) {
      widget.viewModel.setDarkMode.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Successfully changed the dark mode preference."),
        ),
      );
    }

    if (widget.viewModel.setDarkMode.error) {
      widget.viewModel.setDarkMode.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Dark Mode preference Change had some issues. Please try again."),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar({required bool isMobile}) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest, 
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
                icon: Icon(
                  Icons.menu, 
                  color: Theme.of(context).colorScheme.onSurface, 
                  size: 25
                ), 
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
                  if (!isMobile) Text(
                    'EPHOR', 
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(222), 
                      fontWeight: FontWeight.bold, 
                      fontSize: 18.0
                    )
                  ),
                ],
              ),
              
              // Search Bar: Takes up available space
              Expanded(
                child: !_showSearch
                  ? SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 4.0, 
                        horizontal: isMobile ? 16 : 48
                      ),
                      child: ConstrainedBox(
                        // Max width ensures search bar doesn't look too wide on huge screens
                        constraints: const BoxConstraints(maxWidth: 500), 
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                                width: 1.0,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface
                          ),
                          cursorColor: Theme.of(context).colorScheme.primary, // This is already good
                        ),
                      ),
                    ),
              ),
              
              // Action Buttons (Info, Notifications, Profile)
              Row(
                // Use responsive checks here if you wanted to hide some buttons on mobile
                children: [
                  // Use Responsive.isMobile to decide if to show or not
                  IconButton(
                    icon: Icon(
                      Icons.info_outline, 
                      color: Theme.of(context).colorScheme.onSurface, 
                      size: 25
                    ),
                    onPressed: _showInfoPlaceholder
                  ),
                  
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none, 
                      color: Theme.of(context).colorScheme.onSurface, 
                      size: 25
                    ), 
                    onPressed: _showNotificationsPlaceholder
                  ),
                  
                  const SizedBox(width: 15.0), 

                  // User Profile/Avatar Icon
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: CachedNetworkImage(
                      width: 32,
                      height: 32,
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
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
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
                        PopupMenuItem(
                          onTap: null,
                          child: Row(
                            children: [
                              PopupMenuItem(
                                value: 'light_mode',
                                child: Icon(
                                  Icons.light_mode,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                              ),
                              PopupMenuItem(
                                value: 'dark_mode',
                                child: Icon(
                                  Icons.dark_mode,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                              ),
                              PopupMenuItem(
                                value: 'follow_system_mode',
                                child: Icon(
                                  Icons.brightness_auto,
                                  color: Theme.of(context).colorScheme.onSurface,
                                )
                              )
                            ],
                          )
                        ),
                        PopupMenuItem<String>(
                          value: 'edit_profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_outlined, 
                                color: Theme.of(context).colorScheme.onSurface
                              ), 
                              SizedBox(
                                width: 8
                              ), 
                              Text('Edit Profile')
                            ]
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout, 
                                color: Theme.of(context).colorScheme.onSurface
                              ), 
                              SizedBox(
                                width: 8
                              ), 
                              Text('Logout')
                            ]
                          ),
                        ),
                      ];
                    },
                    onSelected: (String result) {
                      switch (result) {
                        case 'edit_profile':
                          _handleEditProfile(context);
                          break;
                        case 'logout':
                          _handleLogout(context);
                          break;
                        case 'light_mode':
                          widget.viewModel.setDarkMode.execute(ThemeMode.light);
                          break;
                        case 'dark_mode':
                          widget.viewModel.setDarkMode.execute(ThemeMode.dark);
                          break;
                        case 'follow_system_mode':
                          widget.viewModel.setDarkMode.execute(ThemeMode.system);
                          break;
                      }
                    }
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
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    _showSearch = _shouldShowSearch(location);
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel.logout,
        widget.viewModel.currentUser
      ]), 
      builder: (context, _) {
        final isMobile = Responsive.isMobile(context);

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