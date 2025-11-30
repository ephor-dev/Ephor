import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;

  const SvgIcon(this.assetName, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;

    return ConstrainedBox(
      constraints: BoxConstraints.tight(
        Size(
          size,
          size,
        )
      ),
      child: SvgPicture.asset(
        assetName,
        width: size,
        height: size,
        colorFilter: iconColor != null 
            ? ColorFilter.mode(iconColor, BlendMode.srcIn) 
            : null,
      ),
    );
  }
}