import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/biometria.dart';
import '../services/biometria_service.dart';
import '../widgets/app_footer.dart';
import '../widgets/aura_logo.dart';

class StatisticsScreen extends StatefulWidget {
  final int usuarioId;
  final String nombre;

  const StatisticsScreen({
    super.key,
    required this.usuarioId,
    required this.nombre,
  });

  @override
  State<StatisticsScreen> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final BiometriaService _service = BiometriaService();

  late Future<List<Biometria>> _historial;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _historial = _service.obtenerHistorial(
      widget.usuarioId,
    );
  }

  void _actualizar() {
    setState(_cargar);
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
      body: FutureBuilder<List<Biometria>>(
        future: _historial,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorEstadisticas(
              onRetry: _actualizar,
            );
          }

          final datos = snapshot.data ?? [];

          if (datos.isEmpty) {
            return _SinDatos(
              onRetry: _actualizar,
            );
          }

          return _ContenidoEstadisticas(
            nombre: widget.nombre,
            datos: datos,
          );
        },
      ),
    );
  }
}

class _ContenidoEstadisticas extends StatelessWidget {
  final String nombre;
  final List<Biometria> datos;

  const _ContenidoEstadisticas({
    required this.nombre,
    required this.datos,
  });

  double get promedioRitmo {
    final suma = datos.fold<int>(
      0,
      (total, dato) => total + dato.ritmoCardiaco,
    );

    return suma / datos.length;
  }

  double get promedioSueno {
    final suma = datos.fold<double>(
      0,
      (total, dato) => total + dato.horasSueno,
    );

    return suma / datos.length;
  }

  double get promedioPasos {
    final suma = datos.fold<int>(
      0,
      (total, dato) => total + dato.pasos,
    );

    return suma / datos.length;
  }

  int get totalActividad {
    return datos.fold<int>(
      0,
      (total, dato) => total + dato.actividadMinutos,
    );
  }

  List<Biometria> get datosGrafica {
    if (datos.length <= 10) return datos;

    return datos.sublist(datos.length - 10);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _encabezado(),
          Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                children: [
                  Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: [
                      _ResumenCard(
                        titulo: 'Ritmo promedio',
                        valor:
                            '${promedioRitmo.toStringAsFixed(0)} lpm',
                        icono: Icons.favorite_outline,
                        color: const Color(0xFFE5484D),
                      ),
                      _ResumenCard(
                        titulo: 'Pasos promedio',
                        valor: promedioPasos.toStringAsFixed(0),
                        icono: Icons.directions_walk,
                        color: const Color(0xFF5145CD),
                      ),
                      _ResumenCard(
                        titulo: 'Sueño promedio',
                        valor:
                            '${promedioSueno.toStringAsFixed(1)} h',
                        icono: Icons.bedtime_outlined,
                        color: const Color(0xFF7A5AF8),
                      ),
                      _ResumenCard(
                        titulo: 'Actividad acumulada',
                        valor: '$totalActividad min',
                        icono: Icons.timer_outlined,
                        color: const Color(0xFF039855),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  _GraficaRitmoCardiaco(
                    datos: datosGrafica,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Registros analizados: ${datos.length}',
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

  Widget _encabezado() {
    return Container(
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
            'Estadísticas de $nombre',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Evolución de la información registrada '
            'por tu smartwatch.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficaRitmoCardiaco extends StatelessWidget {
  final List<Biometria> datos;

  const _GraficaRitmoCardiaco({
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    final puntos = List.generate(
      datos.length,
      (index) => FlSpot(
        index.toDouble(),
        datos[index].ritmoCardiaco.toDouble(),
      ),
    );

    final valores = datos
        .map((dato) => dato.ritmoCardiaco)
        .toList();

    final minimo = valores.reduce(
      (a, b) => a < b ? a : b,
    );

    final maximo = valores.reduce(
      (a, b) => a > b ? a : b,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        30,
        20,
      ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolución del ritmo cardiaco',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Últimas 10 lecturas registradas',
            style: TextStyle(
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (datos.length - 1)
                    .toDouble()
                    .clamp(1, double.infinity),
                minY: (minimo - 10)
                    .toDouble()
                    .clamp(0, double.infinity),
                maxY: (maximo + 10).toDouble(),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    axisNameWidget: Text('LPM'),
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 ||
                            index >= datos.length) {
                          return const SizedBox.shrink();
                        }

                        final fecha = datos[index].fecha;

                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 8),
                          child: Text(
                            '${fecha.day}/${fecha.month}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF667085),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: puntos,
                    isCurved: true,
                    color: const Color(0xFFE5484D),
                    barWidth: 4,
                    dotData: const FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE5484D)
                          .withValues(alpha: 0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _ResumenCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
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
              backgroundColor:
                  color.withValues(alpha: 0.12),
              child: Icon(icono, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
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

class _ErrorEstadisticas extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorEstadisticas({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _MensajeEstadisticas(
      icono: Icons.cloud_off_outlined,
      mensaje: 'No fue posible obtener las estadísticas.',
      onRetry: onRetry,
    );
  }
}

class _SinDatos extends StatelessWidget {
  final VoidCallback onRetry;

  const _SinDatos({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _MensajeEstadisticas(
      icono: Icons.query_stats_rounded,
      mensaje: 'Todavía no existen lecturas biométricas.',
      onRetry: onRetry,
    );
  }
}

class _MensajeEstadisticas extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final VoidCallback onRetry;

  const _MensajeEstadisticas({
    required this.icono,
    required this.mensaje,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 64,
            color: const Color(0xFF98A2B3),
          ),
          const SizedBox(height: 16),
          Text(mensaje),
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