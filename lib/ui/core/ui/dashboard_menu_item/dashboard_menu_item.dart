
import 'package:flutter/material.dart';

class DashboardMenuItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DashboardMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap
  });
  
  @override
  State<DashboardMenuItem> createState() => _DashboardMenuItemState();
}

class _DashboardMenuItemState extends State<DashboardMenuItem> {
  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = widget.isSelected
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
          widget.icon,
          color: Colors.black,
          size: 25,
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}