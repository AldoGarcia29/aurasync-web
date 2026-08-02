import 'dart:async';

import 'package:flutter/material.dart';

import '../models/search_result.dart';
import '../services/search_service.dart';
import 'devices_screen.dart';
import 'privacy_screen.dart';
import '../widgets/app_footer.dart';
import 'wellness_screen.dart';
import 'statistics_screen.dart';
import 'contact_screen.dart';

class SearchScreen extends StatefulWidget {
  final int usuarioId;
  final String nombre;

  const SearchScreen({
    super.key,
    required this.usuarioId,
    required this.nombre,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _controller = TextEditingController();

  Timer? _debounce;

  List<SearchResult> _resultados = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _buscar('');
  }

  void _alCambiarTexto(String texto) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _buscar(texto),
    );
  }

  Future<void> _buscar(String texto) async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados = await _searchService.buscar(texto);

      if (!mounted) return;

      setState(() {
        _resultados = resultados;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _resultados = [];
        _error =
            'No fue posible conectarse con el buscador. '
            'Comprueba que Spring Boot y Elasticsearch estén encendidos.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _abrirResultado(SearchResult resultado) {
  switch (resultado.ruta) {
    case '/':
      Navigator.pop(context);
      break;

    case '/dispositivos':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DevicesScreen(
            usuarioId: widget.usuarioId,
            nombre: widget.nombre,
          ),
        ),
      );
      break;

    case '/aviso-privacidad':
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PrivacyScreen(),
        ),
      );
      break;

    case '/bienestar':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WellnessScreen(
        usuarioId: widget.usuarioId,
        nombre: widget.nombre,
      ),
    ),
  );
  break;

case '/estadisticas':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StatisticsScreen(
        usuarioId: widget.usuarioId,
        nombre: widget.nombre,
      ),
    ),
  );
  break;

   case '/contacto':
case '/configuracion':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ContactScreen(),
    ),
  );
  break;

    default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No existe una pantalla para la ruta ${resultado.ruta}.',
          ),
        ),
      );
  }
}


  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Buscador'),
        backgroundColor: const Color(0xFF4338CA),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _construirEncabezado(),
          Expanded(
            child: _construirContenido(),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _construirEncabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4338CA),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '¿Qué deseas encontrar?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Busca contenido y secciones dentro de AuraSync.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
            ),
            child: TextField(
              controller: _controller,
              onChanged: _alCambiarTexto,
              decoration: InputDecoration(
                hintText:
                    'Buscar respiración, ritmo cardíaco, dispositivos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _buscar('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => _buscar(_controller.text),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_resultados.isEmpty) {
      return const Center(
        child: Text(
          'No encontramos resultados.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 700
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(28),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.8,
          ),
          itemCount: _resultados.length,
          itemBuilder: (context, index) {
            final resultado = _resultados[index];

            return Card(
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _abrirResultado(resultado),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultado.titulo,
                        style: const TextStyle(
                          color: Color(0xFF4338CA),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          resultado.descripcion,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text(
                            'Ir a la sección',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}