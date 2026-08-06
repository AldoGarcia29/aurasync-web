import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/aura_logo.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _correoController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _ocultarPassword = true;
  bool _recordarme = false;
  bool _cargando = false;
  String? _mensajeError;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
  FocusScope.of(context).unfocus();

  setState(() {
    _mensajeError = null;
  });

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _cargando = true;
  });

  try {
    final usuario =
        await AuthService.iniciarSesion(
      correo: _correoController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          usuarioId: usuario.id,
  nombre: usuario.nombre,
        ),
      ),
    );
  } on AuthException catch (error) {
    if (!mounted) return;

    setState(() {
      _mensajeError = error.mensaje;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      _mensajeError =
          'Ocurrió un error inesperado.';
    });
  } finally {
    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }
}


Future<void> _abrirRegistro() async {
  final creado = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const RegisterScreen(),
    ),
  );

  if (creado == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cuenta creada. Ahora puedes iniciar sesión.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool esEscritorio = constraints.maxWidth >= 850;

          return Row(
            children: [
              if (esEscritorio)
                const Expanded(
                  flex: 11,
                  child: _PanelBienvenida(),
                ),
              Expanded(
                flex: esEscritorio ? 9 : 1,
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: esEscritorio ? 70 : 28,
                        vertical: 36,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 440,
                        ),
                        child: _construirFormulario(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: AuraLogo(size: 48),
          ),
          const SizedBox(height: 44),
          const Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF101828),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Inicia sesión para continuar cuidando de ti',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 36),

          const Text(
            'Correo electrónico',
            style: TextStyle(
              color: Color(0xFF344054),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _correoController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [
              AutofillHints.email,
            ],
            decoration: _crearDecoracion(
              texto: 'manuel@email.com',
              icono: Icons.mail_outline_rounded,
            ),
            validator: (valor) {
              final correo = valor?.trim() ?? '';

              if (correo.isEmpty) {
                return 'Ingresa tu correo electrónico.';
              }

              final expresionCorreo = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              );

              if (!expresionCorreo.hasMatch(correo)) {
                return 'Ingresa un correo válido.';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Contraseña',
            style: TextStyle(
              color: Color(0xFF344054),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: _passwordController,
            obscureText: _ocultarPassword,
            autofillHints: const [
              AutofillHints.password,
            ],
            onFieldSubmitted: (_) => _iniciarSesion(),
            decoration: _crearDecoracion(
              texto: 'Ingresa tu contraseña',
              icono: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                tooltip: _ocultarPassword
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                onPressed: () {
                  setState(() {
                    _ocultarPassword = !_ocultarPassword;
                  });
                },
                icon: Icon(
                  _ocultarPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Ingresa tu contraseña.';
              }

              if (valor.length < 8) {
                return 'Debe contener al menos 8 caracteres.';
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

        

          if (_mensajeError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mensajeError!,
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _cargando
                  ? null
                  : _iniciarSesion,
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF5145CD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _cargando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text(
      '¿Aún no tienes una cuenta?',
      style: TextStyle(
        color: Color(0xFF667085),
      ),
    ),
    TextButton(
      onPressed: _abrirRegistro,
      child: const Text(
        'Registrarse',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ],
),

          const SizedBox(height: 28),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 15,
                color: Color(0xFF98A2B3),
              ),
              SizedBox(width: 6),
              Text(
                'Tus datos permanecen protegidos',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _crearDecoracion({
    required String texto,
    required IconData icono,
  }) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(
        icono,
        color: const Color(0xFF667085),
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF5145CD),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFF04438),
        ),
      ),
    );
  }
}

class _PanelBienvenida extends StatelessWidget {
  const _PanelBienvenida();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF292466),
            Color(0xFF6254D9),
            Color(0xFFB46FC7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _crearCirculo(
              330,
              const Color(0xFF79A7FF),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -70,
            child: _crearCirculo(
              300,
              const Color(0xFFFF77C8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 70,
              vertical: 58,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuraLogo(
                  size: 46,
                  textColor: Colors.white,
                ),
                const Spacer(),
                const Icon(
                  Icons.self_improvement_rounded,
                  size: 105,
                  color: Colors.white,
                ),
                const SizedBox(height: 26),
                const Text(
                  'Tu bienestar,\nsiempre conectado.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sincroniza tu smartwatch, conoce tus emociones\n'
                  'y encuentra un momento de calma cada día.',
                  style: TextStyle(
                    color: Color(0xFFE9E7FF),
                    fontSize: 18,
                    height: 1.55,
                  ),
                ),
                const Spacer(),
                const Wrap(
                  spacing: 28,
                  runSpacing: 15,
                  children: [
                    _Caracteristica(
                      icono: Icons.favorite_rounded,
                      texto: 'Salud',
                    ),
                    _Caracteristica(
                      icono: Icons.shield_rounded,
                      texto: 'Privacidad',
                    ),
                    _Caracteristica(
                      icono: Icons.watch_rounded,
                      texto: 'Conexión',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _crearCirculo(
    double tamanio,
    Color color,
  ) {
    return Container(
      width: tamanio,
      height: tamanio,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}

class _Caracteristica extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Caracteristica({
    required this.icono,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icono,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 7),
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}