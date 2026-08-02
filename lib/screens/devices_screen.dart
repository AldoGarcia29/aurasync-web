import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/device_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';

class DevicesScreen extends StatefulWidget {
  final int usuarioId;
  final String nombre;

  const DevicesScreen({
    super.key,
    required this.usuarioId,
    required this.nombre,
  });

  @override
  State<DevicesScreen> createState() =>
      _DevicesScreenState();
}

class _DevicesScreenState
    extends State<DevicesScreen> {
  CodigoVinculacion? _codigo;
  Timer? _timer;
  Duration _tiempoRestante = Duration.zero;
  bool _cargando = false;
  String? _error;

  List<Dispositivo> _dispositivos = [];
bool _cargandoDispositivos = true;
String? _errorDispositivos;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
void initState() {
  super.initState();
  _cargarDispositivos();
}

Future<void> _cargarDispositivos() async {
  setState(() {
    _cargandoDispositivos = true;
    _errorDispositivos = null;
  });

  try {
    final dispositivos =
        await DeviceService.obtenerDispositivos(
      usuarioId: widget.usuarioId,
    );

    if (!mounted) return;

    setState(() {
      _dispositivos = dispositivos;
    });
  } on DeviceException catch (error) {
    if (!mounted) return;

    setState(() {
      _errorDispositivos = error.mensaje;
    });
  } finally {
    if (mounted) {
      setState(() {
        _cargandoDispositivos = false;
      });
    }
  }
}

  Future<void> _generarCodigo() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado =
          await DeviceService.generarCodigo(
        usuarioId: widget.usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _codigo = resultado;
      });

      _iniciarTemporizador();
    } on DeviceException catch (error) {
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

  void _iniciarTemporizador() {
    _timer?.cancel();
    _actualizarTiempo();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _actualizarTiempo(),
    );
  }

  void _actualizarTiempo() {
    if (_codigo == null) return;

    final diferencia = _codigo!.fechaExpiracion
        .difference(DateTime.now());

    if (diferencia.isNegative) {
      _timer?.cancel();

      if (mounted) {
        setState(() {
          _tiempoRestante = Duration.zero;
        });
      }

      return;
    }

    if (mounted) {
      setState(() {
        _tiempoRestante = diferencia;
      });
    }
  }

  String get _tiempoTexto {
    final minutos = _tiempoRestante.inMinutes;

    final segundos =
        _tiempoRestante.inSeconds.remainder(60);

    return '${minutos.toString().padLeft(2, '0')}:'
        '${segundos.toString().padLeft(2, '0')}';
  }

  bool get _codigoVigente {
    return _codigo != null &&
        _tiempoRestante > Duration.zero;
  }

  Future<void> _copiarCodigo() async {
    if (_codigo == null) return;

    await Clipboard.setData(
      ClipboardData(text: _codigo!.codigo),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Código copiado al portapapeles.',
        ),
      ),
    );
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 22,
            ),
            child: Center(
              child: Text(
                widget.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),
                child: Column(
                  children: [
                    _buildDevicesSection(),
                    const SizedBox(height: 25),
                    _buildPairingCard(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 52,
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
            Icons.devices_rounded,
            color: Colors.white,
            size: 62,
          ),
          SizedBox(height: 16),
          Text(
            'Dispositivos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Administra y vincula tus dispositivos AuraSync.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE9E7FF),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesSection() {
  if (_cargandoDispositivos) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: _cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5145CD),
        ),
      ),
    );
  }

  if (_errorDispositivos != null) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD92D20),
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            _errorDispositivos!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _cargarDispositivos,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Volver a intentar',
            ),
          ),
        ],
      ),
    );
  }

  if (_dispositivos.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.devices_other_rounded,
            color: Color(0xFF98A2B3),
            size: 55,
          ),
          SizedBox(height: 15),
          Text(
            'No hay dispositivos vinculados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Genera un código para conectar '
            'tu primer smartwatch.',
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Mis dispositivos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargarDispositivos,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      ..._dispositivos.map(
        (dispositivo) =>
            _buildDeviceCard(dispositivo),
      ),
    ],
  );
}

Widget _buildDeviceCard(
  Dispositivo dispositivo,
) {
  final esReloj =
      dispositivo.tipo.toLowerCase()
          .contains('smartwatch');

  final estadoActivo =
      dispositivo.estado.toLowerCase() ==
              'conectado' ||
          dispositivo.estado.toLowerCase() ==
              'vinculado' ||
          dispositivo.estado.toLowerCase() ==
              'sincronizada';

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(26),
    decoration: _cardDecoration(),
    child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor:
              const Color(0xFFEDEBFF),
          child: Icon(
            esReloj
                ? Icons.watch_rounded
                : Icons.tv_rounded,
            color: const Color(0xFF5145CD),
            size: 34,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                dispositivo.nombre,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dispositivo.tipo,
                style: const TextStyle(
                  color: Color(0xFF667085),
                ),
              ),
              if (esReloj) ...[
                const SizedBox(height: 6),
                Text(
                  dispositivo.pinHabilitado
                      ? 'PIN configurado'
                      : 'PIN pendiente',
                  style: TextStyle(
                    color: dispositivo.pinHabilitado
                        ? const Color(0xFF12B76A)
                        : const Color(0xFFF79009),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        Chip(
          avatar: Icon(
            estadoActivo
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: estadoActivo
                ? const Color(0xFF12B76A)
                : const Color(0xFFF79009),
            size: 18,
          ),
          label: Text(dispositivo.estado),
        ),
      ],
    ),
  );
}

  Widget _buildPairingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(34),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEBFF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.add_link_rounded,
              color: Color(0xFF5145CD),
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vincular un smartwatch',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Genera un código temporal e introdúcelo '
            'en la aplicación AuraSync del reloj.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFB42318),
                ),
              ),
            ),
          ],
          if (_codigo != null) ...[
            const SizedBox(height: 28),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: _codigoVigente
                    ? const Color(0xFFF5F3FF)
                    : const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _codigoVigente
                      ? const Color(0xFFB9B2FF)
                      : const Color(0xFFD0D5DD),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _codigoVigente
                        ? 'Código de vinculación'
                        : 'Código expirado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _codigo!.codigo,
                    style: TextStyle(
                      color: _codigoVigente
                          ? const Color(0xFF5145CD)
                          : const Color(0xFF98A2B3),
                      fontSize: 44,
                      letterSpacing: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _codigoVigente
                        ? 'Expira en $_tiempoTexto'
                        : 'Genera un código nuevo para continuar',
                    style: TextStyle(
                      color: _codigoVigente
                          ? const Color(0xFFD92D20)
                          : const Color(0xFF667085),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_codigoVigente) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _copiarCodigo,
                      icon: const Icon(
                        Icons.copy_rounded,
                      ),
                      label: const Text(
                        'Copiar código',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  _cargando ? null : _generarCodigo,
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF5145CD),
                padding: const EdgeInsets.symmetric(
                  horizontal: 27,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              icon: _cargando
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(
                      Icons.password_rounded,
                    ),
              label: Text(
                _cargando
                    ? 'Generando...'
                    : _codigo == null
                        ? 'Generar código temporal'
                        : 'Generar código nuevo',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x11000000),
          blurRadius: 25,
          offset: Offset(0, 10),
        ),
      ],
    );
  }
}