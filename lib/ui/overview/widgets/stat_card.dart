import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color? color;
  final double height; 

  const StatCard({
    super.key, 
    required this.title,
    required this.value,
    required this.subtitle,
    this.color,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = ThemeData.light().colorScheme.surfaceContainerLowest;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Card(
        color: color,
        shadowColor: Colors.black,
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: textColor, fontSize: 18)),
              
              Text(value, style: TextStyle(color: textColor, fontSize: 56, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(subtitle, style: TextStyle(color: textColor, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}