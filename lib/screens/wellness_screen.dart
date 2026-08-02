import 'package:flutter/material.dart';

import '../models/biometria.dart';
import '../services/biometria_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';

class WellnessScreen extends StatefulWidget {
  final int usuarioId;
  final String nombre;

  const WellnessScreen({
    super.key,
    required this.usuarioId,
    required this.nombre,
  });

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final BiometriaService _service = BiometriaService();

  late Future<Biometria> _lectura;

  @override
  void initState() {
    super.initState();
    _lectura = _service.obtenerUltima(widget.usuarioId);
  }

  void _actualizar() {
    setState(() {
      _lectura = _service.obtenerUltima(widget.usuarioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        title: const AuraLogo(size: 38),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<Biometria>(
        future: _lectura,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorBienestar(
              onRetry: _actualizar,
            );
          }

          return _ContenidoBienestar(
            nombre: widget.nombre,
            biometria: snapshot.data!,
          );
        },
      ),
    );
  }
}

class _ContenidoBienestar extends StatelessWidget {
  final String nombre;
  final Biometria biometria;

  const _ContenidoBienestar({
    required this.nombre,
    required this.biometria,
  });

  String get estado {
    if (biometria.ritmoCardiaco > 100 ||
        biometria.horasSueno < 6) {
      return 'Necesitas descansar';
    }

    if (biometria.pasos < 3000) {
      return 'Actividad baja';
    }

    return 'Estado equilibrado';
  }

  String get recomendacion {
    if (biometria.ritmoCardiaco > 100) {
      return 'Tu ritmo cardiaco se encuentra elevado. '
          'Realiza una pausa y practica respiración profunda.';
    }

    if (biometria.horasSueno < 6) {
      return 'Dormiste menos de lo recomendable. '
          'Procura descansar y reducir actividades intensas.';
    }

    if (biometria.pasos < 3000) {
      return 'Has tenido poca actividad. Una caminata corta '
          'puede ayudarte a mejorar tu energía.';
    }

    return 'Tus indicadores se encuentran estables. '
        'Continúa cuidando tu descanso y actividad diaria.';
  }

  Color get colorEstado {
    if (biometria.ritmoCardiaco > 100 ||
        biometria.horasSueno < 6) {
      return const Color(0xFFD92D20);
    }

    if (biometria.pasos < 3000) {
      return const Color(0xFFF79009);
    }

    return const Color(0xFF039855);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 44,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF5548C8),
                  Color(0xFFB36FC6),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Bienestar de $nombre',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Información obtenida desde tu smartwatch.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1200,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorEstado.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: colorEstado,
                          size: 42,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estado estimado',
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                ),
                              ),
                              Text(
                                estado,
                                style: TextStyle(
                                  color: colorEstado,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      _DatoCard(
                        icono: Icons.favorite_outline_rounded,
                        titulo: 'Ritmo cardiaco',
                        valor: '${biometria.ritmoCardiaco} lpm',
                        color: const Color(0xFFE5484D),
                      ),
                      _DatoCard(
                        icono: Icons.directions_walk_rounded,
                        titulo: 'Pasos',
                        valor: '${biometria.pasos}',
                        color: const Color(0xFF5145CD),
                      ),
                      _DatoCard(
                        icono: Icons.timer_outlined,
                        titulo: 'Actividad',
                        valor:
                            '${biometria.actividadMinutos} min',
                        color: const Color(0xFF039855),
                      ),
                      _DatoCard(
                        icono: Icons.bedtime_outlined,
                        titulo: 'Sueño',
                        valor: '${biometria.horasSueno} h',
                        color: const Color(0xFF7A5AF8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Color(0xFF5145CD),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Recomendación para ti',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          recomendacion,
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Última lectura: ${_formatearFecha(biometria.fecha)}',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    String dosDigitos(int valor) =>
        valor.toString().padLeft(2, '0');

    return '${dosDigitos(fecha.day)}/'
        '${dosDigitos(fecha.month)}/${fecha.year} '
        '${dosDigitos(fecha.hour)}:'
        '${dosDigitos(fecha.minute)}';
  }
}

class _DatoCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;

  const _DatoCard({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 15,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icono, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBienestar extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorBienestar({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.monitor_heart_outlined,
            size: 64,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Todavía no fue posible obtener datos biométricos.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}