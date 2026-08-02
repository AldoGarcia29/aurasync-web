import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/aura_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false;
  String? _error;

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _error = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await AuthService.registrar(
        nombre: _nombreController.text,
        correo: _correoController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.mensaje;
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF101828),
        title: const AuraLogo(size: 34),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            padding: const EdgeInsets.all(34),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF5145CD),
                    size: 45,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Crear una cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Comienza a cuidar tu bienestar con AuraSync',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _campo(
                    controller: _nombreController,
                    etiqueta: 'Nombre completo',
                    icono: Icons.person_outline_rounded,
                    validator: (value) {
                      if ((value?.trim().length ?? 0) < 3) {
                        return 'Ingresa tu nombre completo.';
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
                      final expresion = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      );

                      if (!expresion.hasMatch(correo)) {
                        return 'Ingresa un correo válido.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _campoPassword(
                    controller: _passwordController,
                    etiqueta: 'Contraseña',
                    ocultar: _ocultarPassword,
                    onVisibility: () {
                      setState(() {
                        _ocultarPassword =
                            !_ocultarPassword;
                      });
                    },
                    validator: (value) {
                      if ((value?.length ?? 0) < 8) {
                        return 'Usa al menos 8 caracteres.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _campoPassword(
                    controller: _confirmarController,
                    etiqueta: 'Confirmar contraseña',
                    ocultar: _ocultarConfirmacion,
                    onVisibility: () {
                      setState(() {
                        _ocultarConfirmacion =
                            !_ocultarConfirmacion;
                      });
                    },
                    onSubmitted: (_) => _registrar(),
                    validator: (value) {
                      if (value !=
                          _passwordController.text) {
                        return 'Las contraseñas no coinciden.';
                      }

                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F0),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFB42318),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed:
                          _cargando ? null : _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF5145CD),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                      child: _cargando
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    child: const Text(
                      'Ya tengo una cuenta',
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _decoracion(
        etiqueta,
        icono,
      ),
    );
  }

  Widget _campoPassword({
    required TextEditingController controller,
    required String etiqueta,
    required bool ocultar,
    required VoidCallback onVisibility,
    required String? Function(String?) validator,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: ocultar,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: _decoracion(
        etiqueta,
        Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          onPressed: onVisibility,
          icon: Icon(
            ocultar
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono,
  ) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFD0D5DD),
        ),
      ),
    );
  }
}