class LoginValidator {
  static String? validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    final expresion = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!expresion.hasMatch(correo)) {
      return 'Ingresa un correo válido.';
    }

    return null;
  }

  static String? validarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contraseña.';
    }

    if (valor.length < 8) {
      return 'Debe contener al menos 8 caracteres.';
    }

    return null;
  }
}