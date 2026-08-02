import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';
import 'login_screen.dart';
import 'privacy_screen.dart';
import 'devices_screen.dart';
import 'search_screen.dart';
import 'wellness_screen.dart';
import 'statistics_screen.dart';
import 'contact_screen.dart';
import '../models/biometria.dart';
import '../services/biometria_service.dart';
import '../services/device_service.dart';

class HomeScreen extends StatelessWidget {
  final int usuarioId;
  final String nombre;

  const HomeScreen({super.key, required this.usuarioId, required this.nombre});

  Future<void> _cerrarSesion(BuildContext context) async {
    await AuthService.cerrarSesion();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _abrirPrivacidad(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
    );
  }

  void _abrirDispositivos(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DevicesScreen(usuarioId: usuarioId, nombre: nombre),
      ),
    );
  }

  void _abrirBuscador(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(usuarioId: usuarioId, nombre: nombre),
      ),
    );
  }

  void _abrirBienestar(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WellnessScreen(usuarioId: usuarioId, nombre: nombre),
      ),
    );
  }

  void _abrirEstadisticas(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(usuarioId: usuarioId, nombre: nombre),
      ),
    );
  }

  void _abrirContacto(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      drawer: _MenuLateral(
        nombre: nombre,
        onDevices: () => _abrirDispositivos(context),
        onWellness: () => _abrirBienestar(context),
        onStatistics: () => _abrirEstadisticas(context),
        onSearch: () => _abrirBuscador(context),
        onPrivacy: () => _abrirPrivacidad(context),
        onContact: () => _abrirContacto(context),
        onLogout: () => _cerrarSesion(context),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const AuraLogo(size: 38),
        actions: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF5145CD),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: const Color(0xFFEDEBFF),
            child: Text(
              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Color(0xFF5145CD),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              nombre,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF101828),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(nombre: nombre),
            Padding(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: _HomeDataSection(
  usuarioId: usuarioId,
  nombre: nombre,
),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  final String nombre;
  final VoidCallback onPrivacy;
  final VoidCallback onLogout;
  final VoidCallback onDevices;
  final VoidCallback onSearch;
  final VoidCallback onWellness;
  final VoidCallback onStatistics;
  final VoidCallback onContact;

  const _MenuLateral({
    required this.nombre,
    required this.onDevices,
    required this.onSearch,
    required this.onWellness,
    required this.onStatistics,
    required this.onContact,
    required this.onPrivacy,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF302A78), Color(0xFF6254D9)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AuraLogo(size: 42, textColor: Colors.white),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Color(0xFF5145CD),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Cuenta AuraSync',
                    style: TextStyle(color: Color(0xFFDCD8FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Inicio'),
              selected: true,
              selectedColor: const Color(0xFF5145CD),
              selectedTileColor: const Color(0xFFEDEBFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.self_improvement_rounded),
              title: const Text('Bienestar'),
              onTap: onWellness,
            ),

            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Estadísticas'),
              onTap: onStatistics,
            ),

            ListTile(
              leading: const Icon(Icons.devices_rounded),
              title: const Text('Dispositivos'),
              onTap: onDevices,
            ),

            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('Buscador'),
              onTap: onSearch,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Divider(),
            ),

            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Aviso de privacidad'),
              onTap: onPrivacy,
            ),

            ListTile(
              leading: const Icon(Icons.contact_support_outlined),
              title: const Text('Contacto'),
              onTap: onContact,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Divider(),
            ),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFD92D20),
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Color(0xFFD92D20)),
              ),
              onTap: onLogout,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final String nombre;

  const _HeroSection({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 390),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF5548C8), Color(0xFFB36FC6)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 54),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 40,
          runSpacing: 35,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Buenos días, $nombre! ☀️',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Hoy es un buen día para cuidar '
                    'tu mente y escuchar a tu cuerpo.',
                    style: TextStyle(
                      color: Color(0xFFF0EEFF),
                      fontSize: 20,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'El modo calma iniciará '
                            'próximamente.',
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF101828),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                    ),
                    icon: const Icon(Icons.self_improvement_rounded),
                    label: const Text(
                      'Iniciar modo calma',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 300,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado actual',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Text('😊', style: TextStyle(fontSize: 42)),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tranquilo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Todo se ve bien',
                            style: TextStyle(color: Color(0xFF667085)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Color(0xFFEC4899)),
                      SizedBox(width: 12),
                      Text(
                        '72 lpm',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDataSection extends StatefulWidget {
  final int usuarioId;
  final String nombre;

  const _HomeDataSection({
    required this.usuarioId,
    required this.nombre,
  });

  @override
  State<_HomeDataSection> createState() =>
      _HomeDataSectionState();
}

class _HomeDataSectionState
    extends State<_HomeDataSection> {
  Biometria? _biometria;
  List<Dispositivo> _dispositivos = [];

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados = await Future.wait<Object>([
        BiometriaService().obtenerHistorial(
          widget.usuarioId,
        ),
        DeviceService.obtenerDispositivos(
          usuarioId: widget.usuarioId,
        ),
      ]);

      final historial =
          resultados[0] as List<Biometria>;

      final dispositivos =
          resultados[1] as List<Dispositivo>;

      if (!mounted) return;

      setState(() {
        _biometria = historial.isEmpty
            ? null
            : historial.last;

        _dispositivos = dispositivos;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error =
            'No fue posible cargar tu información.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _abrirDispositivos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DevicesScreen(
          usuarioId: widget.usuarioId,
          nombre: widget.nombre,
        ),
      ),
    ).then((_) => _cargarDatos());
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5145CD),
          ),
        ),
      );
    }

    if (_error != null) {
      return _BaseCard(
        title: 'No pudimos cargar tus datos',
        icon: Icons.cloud_off_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFF667085),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_biometria == null &&
        _dispositivos.isEmpty) {
      return _SyncEmptyCard(
        onConnect: _abrirDispositivos,
      );
    }

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        if (_biometria != null) ...[
          _SummaryCard(
            biometria: _biometria!,
          ),
          _RecommendationCard(
            biometria: _biometria!,
          ),
        ] else
          _SyncEmptyCard(
            onConnect: _abrirDispositivos,
          ),
        if (_dispositivos.isNotEmpty)
          _DeviceCard(
            dispositivo: _dispositivos.first,
          )
        else
          _NoDeviceCard(
            onConnect: _abrirDispositivos,
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Biometria biometria;

  const _SummaryCard({
    required this.biometria,
  });

  @override
  Widget build(BuildContext context) {
    final progresoPasos =
        (biometria.pasos / 8000)
            .clamp(0.0, 1.0)
            .toDouble();

    final progresoActividad =
        (biometria.actividadMinutos / 60)
            .clamp(0.0, 1.0)
            .toDouble();

    final progresoSueno =
        (biometria.horasSueno / 8)
            .clamp(0.0, 1.0)
            .toDouble();

    return _BaseCard(
      title: 'Resumen de hoy',
      icon: Icons.insights_rounded,
      child: Column(
        children: [
          _ProgressItem(
            icon: '🚶',
            label: 'Pasos',
            value: '${biometria.pasos} / 8,000',
            progress: progresoPasos,
          ),
          _ProgressItem(
            icon: '🔥',
            label: 'Actividad',
            value:
                '${biometria.actividadMinutos} min',
            progress: progresoActividad,
          ),
          _ProgressItem(
            icon: '🌙',
            label: 'Sueño',
            value:
                '${biometria.horasSueno.toStringAsFixed(1)} h',
            progress: progresoSueno,
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard
    extends StatelessWidget {
  final Biometria biometria;

  const _RecommendationCard({
    required this.biometria,
  });

  String get _recomendacion {
    if (biometria.ritmoCardiaco > 100) {
      return 'Tu ritmo cardiaco está elevado. '
          'Realiza una pausa y practica '
          'respiración lenta.';
    }

    if (biometria.horasSueno < 6) {
      return 'Tu descanso fue menor al recomendado. '
          'Procura dormir mejor y reducir '
          'actividades intensas.';
    }

    if (biometria.pasos < 3000) {
      return 'Tu actividad ha sido baja. '
          'Una caminata corta puede ayudarte '
          'a recuperar energía.';
    }

    return 'Tus indicadores se encuentran '
        'estables. Mantén tus buenos hábitos '
        'de descanso y actividad.';
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Recomendación para ti',
      icon: Icons.spa_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _recomendacion,
            style: const TextStyle(
              fontSize: 19,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Última lectura: '
            '${biometria.fecha.day}/'
            '${biometria.fecha.month}/'
            '${biometria.fecha.year}',
            style: const TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Dispositivo dispositivo;

  const _DeviceCard({
    required this.dispositivo,
  });

  String get _fechaConexion {
    final fecha = dispositivo.fechaConexion;

    if (fecha == null) {
      return 'Sin información de sincronización';
    }

    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final conectado =
        dispositivo.estado.toLowerCase() ==
            'vinculado';

    return _BaseCard(
      title: 'Dispositivo',
      icon: Icons.watch_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor:
                    Color(0xFFEDEBFF),
                child: Icon(
                  Icons.watch_rounded,
                  color: Color(0xFF5145CD),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dispositivo.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      dispositivo.estado,
                      style: TextStyle(
                        color: conectado
                            ? const Color(0xFF12B76A)
                            : const Color(0xFFF79009),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'Última sincronización: '
            '$_fechaConexion',
            style: const TextStyle(
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncEmptyCard extends StatelessWidget {
  final VoidCallback onConnect;

  const _SyncEmptyCard({
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Empieza a sincronizar',
      icon: Icons.sync_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sincroniza tu smartwatch para '
            'visualizar tus pasos, actividad, '
            'sueño y ritmo cardiaco.',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: onConnect,
            icon: const Icon(
              Icons.watch_rounded,
            ),
            label: const Text(
              'Sincronizar smartwatch',
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDeviceCard extends StatelessWidget {
  final VoidCallback onConnect;

  const _NoDeviceCard({
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Sin dispositivo',
      icon: Icons.watch_off_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Todavía no tienes un smartwatch '
            'vinculado con AuraSync.',
            style: TextStyle(
              color: Color(0xFF667085),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: onConnect,
            icon: const Icon(Icons.add_link_rounded),
            label: const Text(
              'Vincular dispositivo',
            ),
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _BaseCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF5145CD)),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final double progress;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          SizedBox(width: 70, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: const Color(0xFFE4E7EC),
              color: const Color(0xFF8255E8),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
