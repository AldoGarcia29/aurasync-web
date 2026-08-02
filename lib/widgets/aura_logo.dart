import 'package:flutter/material.dart';

class AuraLogo extends StatelessWidget {
  final double size;
  final bool mostrarNombre;
  final Color? textColor;

  const AuraLogo({
    super.key,
    this.size = 44,
    this.mostrarNombre = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD54F),
                Color(0xFFEC4899),
                Color(0xFF7C3AED),
              ],
            ),
          ),
          child: Icon(
            Icons.spa_rounded,
            color: Colors.white,
            size: size * 0.62,
          ),
        ),
        if (mostrarNombre) ...[
          const SizedBox(width: 12),
          Text(
            'AuraSync',
            style: TextStyle(
              color: textColor ?? const Color(0xFF4438CA),
              fontSize: size * 0.65,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}