import 'package:flutter/material.dart';

import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const AuraLogo(size: 36),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 64,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF302A78),
                    Color(0xFF6254D9),
                  ],
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 68,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aviso de privacidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Conoce cómo protegemos la información de AuraSync.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE9E7FF),
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 900,
                ),
                margin: const EdgeInsets.all(28),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 25,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu información nos importa',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101828),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'AuraSync utiliza información personal y datos de '
                      'actividad física para ofrecer recomendaciones de '
                      'bienestar y sincronizar los dispositivos autorizados '
                      'por el usuario.',
                      style: _textStyle,
                    ),
                    SizedBox(height: 30),
                    _PrivacySection(
                      icon: Icons.storage_rounded,
                      title: 'Información recopilada',
                      text:
                          'Podemos almacenar el nombre, correo electrónico, '
                          'recordatorios, ritmo cardiaco, actividad física y '
                          'dispositivos vinculados.',
                    ),
                    _PrivacySection(
                      icon: Icons.favorite_rounded,
                      title: 'Finalidad de la información',
                      text:
                          'Los datos se utilizan para mostrar estadísticas, '
                          'recordatorios y recomendaciones personalizadas de '
                          'bienestar.',
                    ),
                    _PrivacySection(
                      icon: Icons.lock_rounded,
                      title: 'Protección de los datos',
                      text:
                          'Las contraseñas no se almacenan en texto plano. '
                          'AuraSync utiliza controles de autenticación, '
                          'conexiones seguras y restricciones de acceso.',
                    ),
                    _PrivacySection(
                      icon: Icons.visibility_off_rounded,
                      title: 'Privacidad',
                      text:
                          'AuraSync no vende la información personal del '
                          'usuario. El acceso se limita a los servicios '
                          'necesarios para el funcionamiento de la aplicación.',
                    ),
                    _PrivacySection(
                      icon: Icons.contact_mail_rounded,
                      title: 'Contacto',
                      text:
                          'Para solicitar una corrección o eliminación de '
                          'datos, el usuario puede comunicarse con el equipo '
                          'responsable de AuraSync.',
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Última actualización: julio de 2026.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  static const TextStyle _textStyle = TextStyle(
    color: Color(0xFF475467),
    fontSize: 16,
    height: 1.65,
  );
}

class _PrivacySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF5145CD),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF475467),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}