import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  void _proximamente(
    BuildContext context,
    String red,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'El enlace de $red estará disponible próximamente.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF17152C),
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 30,
        runSpacing: 18,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AuraSync',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '© 2026 AuraSync. Todos los derechos reservados.',
                style: TextStyle(
                  color: Color(0xFFCBC8E5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Facebook',
                onPressed: () {
                  _proximamente(context, 'Facebook');
                },
                icon: const Icon(
                  Icons.facebook_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'YouTube',
                onPressed: () {
                  _proximamente(context, 'YouTube');
                },
                icon: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Correo',
                onPressed: () {
                  _proximamente(context, 'correo');
                },
                icon: const Icon(
                  Icons.email_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}