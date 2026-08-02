import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() =>
      _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();

  static const String _correoAuraSync =
      'contacto@aurasync.mx';

  Future<void> _abrirEnlace(Uri enlace) async {
    final abierto = await launchUrl(
      enlace,
      webOnlyWindowName: '_blank',
    );

    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible abrir el enlace.',
          ),
        ),
      );
    }
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enlace = Uri(
      scheme: 'mailto',
      path: _correoAuraSync,
      queryParameters: {
        'subject': _asuntoController.text.trim(),
        'body': '''
Nombre: ${_nombreController.text.trim()}
Correo: ${_correoController.text.trim()}

Mensaje:
${_mensajeController.text.trim()}
''',
      },
    );

    await _abrirEnlace(enlace);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: const Color(0xFF101828),
        elevation: 1,
        title: const AuraLogo(size: 34),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _encabezado(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final escritorio =
                        constraints.maxWidth >= 850;

                    if (escritorio) {
                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _informacionContacto(),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: _formularioContacto(),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _informacionContacto(),
                        const SizedBox(height: 28),
                        _formularioContacto(),
                      ],
                    );
                  },
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 55,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF302A78),
            Color(0xFF6254D9),
            Color(0xFFB36FC6),
          ],
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 52,
          ),
          SizedBox(height: 16),
          Text(
            'Estamos para ayudarte',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Contacta al equipo de AuraSync y resolveremos '
            'tus dudas sobre bienestar y dispositivos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE9E7FF),
              fontSize: 17,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _informacionContacto() {
    return _Tarjeta(
      titulo: 'Información de contacto',
      icono: Icons.contact_support_rounded,
      child: Column(
        children: [
          _ContactoItem(
            icono: Icons.phone_rounded,
            titulo: 'Teléfono',
            valor: '+52 442 385 7290',
            color: const Color(0xFF5145CD),
            onTap: () => _abrirEnlace(
              Uri.parse('tel:+524423857290'),
            ),
          ),
          _ContactoItem(
            icono: Icons.chat_rounded,
            titulo: 'WhatsApp',
            valor: '+52 442 385 7290',
            color: const Color(0xFF25D366),
            onTap: () => _abrirEnlace(
              Uri.parse(
                'https://wa.me/524423857290',
              ),
            ),
          ),
          _ContactoItem(
            icono: Icons.email_rounded,
            titulo: 'Correo electrónico',
            valor: _correoAuraSync,
            color: const Color(0xFFEC4899),
            onTap: () => _abrirEnlace(
              Uri.parse(
                'mailto:$_correoAuraSync',
              ),
            ),
          ),
          _ContactoItem(
            icono: Icons.facebook_rounded,
            titulo: 'Facebook',
            valor: 'AuraSync Bienestar',
            color: const Color(0xFF1877F2),
            onTap: () => _abrirEnlace(
              Uri.parse(
                'https://facebook.com/aurasyncbienestar',
              ),
            ),
          ),
          _ContactoItem(
            icono: Icons.camera_alt_rounded,
            titulo: 'Instagram',
            valor: '@aurasync.bienestar',
            color: const Color(0xFFE4405F),
            onTap: () => _abrirEnlace(
              Uri.parse(
                'https://instagram.com/aurasync.bienestar',
              ),
            ),
          ),
          const Divider(height: 36),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.schedule_rounded,
                color: Color(0xFF5145CD),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Horario de atención\n'
                  'Lunes a viernes, 9:00 a 18:00 horas',
                  style: TextStyle(
                    color: Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _formularioContacto() {
    return _Tarjeta(
      titulo: 'Envíanos un mensaje',
      icono: Icons.send_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _campo(
              controller: _nombreController,
              etiqueta: 'Nombre completo',
              icono: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Ingresa tu nombre.';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),
            _campo(
              controller: _correoController,
              etiqueta: 'Correo electrónico',
              icono: Icons.email_outlined,
              keyboardType:
                  TextInputType.emailAddress,
              validator: (value) {
                final correo = value?.trim() ?? '';

                if (correo.isEmpty ||
                    !correo.contains('@') ||
                    !correo.contains('.')) {
                  return 'Ingresa un correo válido.';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),
            _campo(
              controller: _asuntoController,
              etiqueta: 'Asunto',
              icono: Icons.subject_rounded,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Escribe el asunto.';
                }

                return null;
              },
            ),
            const SizedBox(height: 18),
            _campo(
              controller: _mensajeController,
              etiqueta: '¿Cómo podemos ayudarte?',
              icono: Icons.message_outlined,
              maxLines: 5,
              validator: (value) {
                if (value == null ||
                    value.trim().length < 10) {
                  return 'Escribe un mensaje de al menos 10 caracteres.';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _enviarFormulario,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF5145CD),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  'Enviar mensaje',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: etiqueta,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icono),
        filled: true,
        fillColor: const Color(0xFFF8F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD0D5DD),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFD0D5DD),
          ),
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _Tarjeta({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                color: const Color(0xFF5145CD),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          child,
        ],
      ),
    );
  }
}

class _ContactoItem extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;
  final VoidCallback onTap;

  const _ContactoItem({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icono, color: color),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(valor),
      trailing: const Icon(
        Icons.open_in_new_rounded,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}