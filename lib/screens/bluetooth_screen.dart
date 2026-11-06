import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  // Deben coincidir con los UUID programados en el ESP32.
  final Guid _serviceUuid = Guid(
    '12345678-1234-1234-1234-123456789abc',
  );

  final Guid _characteristicUuid = Guid(
    'abcd1234-1234-1234-1234-123456789abc',
  );

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanningSubscription;
  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  List<ScanResult> _dispositivos = [];

  BluetoothDevice? _dispositivoConectado;

  bool _buscando = false;
  bool _conectando = false;
  bool _conectado = false;

  int? _ritmoCardiaco;
  int? _pasos;

  String _mensaje = 'Presiona “Buscar dispositivo” para comenzar.';

  @override
  void initState() {
    super.initState();

    _scanSubscription = FlutterBluePlus.onScanResults.listen(
          (resultados) {
        if (!mounted) return;

        // Se muestran los dispositivos que anuncian nuestro servicio BLE.
        setState(() {
          _dispositivos = resultados;
        });
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          _mensaje = 'Error durante la búsqueda: $error';
        });
      },
    );

    _scanningSubscription = FlutterBluePlus.isScanning.listen(
          (buscando) {
        if (!mounted) return;

        setState(() {
          _buscando = buscando;
        });
      },
    );
  }

  Future<bool> _solicitarPermisos() async {
    if (!Platform.isAndroid) {
      if (mounted) {
        setState(() {
          _mensaje = 'Esta prueba está preparada para Android.';
        });
      }
      return false;
    }

    final info = await DeviceInfoPlugin().androidInfo;
    final int versionAndroid = info.version.sdkInt;

    final List<Permission> permisos;

    if (versionAndroid >= 31) {
      permisos = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];
    } else {
      permisos = [
        Permission.locationWhenInUse,
      ];
    }

    final resultados = await permisos.request();

    final concedidos = resultados.values.every(
          (estado) => estado.isGranted,
    );

    if (!concedidos && mounted) {
      final denegadoPermanentemente = resultados.values.any(
            (estado) => estado.isPermanentlyDenied,
      );

      setState(() {
        _mensaje = denegadoPermanentemente
            ? 'Los permisos están bloqueados. '
            'Abre la configuración de la aplicación y habilítalos.'
            : 'Se requieren los permisos para buscar y conectar el ESP32.';
      });
    }

    return concedidos;
  }

  Future<void> _buscarDispositivos() async {
    try {
      final permisosConcedidos = await _solicitarPermisos();

      if (!permisosConcedidos || !mounted) return;

      final disponible = await FlutterBluePlus.isSupported;

      if (!disponible) {
        setState(() {
          _mensaje = 'Este teléfono no admite Bluetooth Low Energy.';
        });
        return;
      }

      final estado = await FlutterBluePlus.adapterState.first;

      if (!mounted) return;

      if (estado != BluetoothAdapterState.on) {
        setState(() {
          _mensaje = 'Activa el Bluetooth del teléfono e inténtalo de nuevo.';
        });
        return;
      }

      if (_conectado || _conectando) {
        setState(() {
          _mensaje = 'Desconecta el dispositivo antes de buscar otro.';
        });
        return;
      }

      setState(() {
        _dispositivos = [];
        _mensaje = 'Buscando AuraSync Watch durante 12 segundos...';
      });

      await FlutterBluePlus.startScan(
        withServices: [_serviceUuid],
        timeout: const Duration(seconds: 12),
      );

      await FlutterBluePlus.isScanning
          .where((buscando) => !buscando)
          .first;

      if (!mounted) return;

      setState(() {
        _mensaje = _dispositivos.isEmpty
            ? 'No se encontró el ESP32. Comprueba que esté encendido '
            'y cerca del teléfono.'
            : 'Selecciona AuraSync Watch para conectarte.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _mensaje = 'No se pudo iniciar la búsqueda: $error';
      });
    }
  }

  Future<void> _conectar(BluetoothDevice dispositivo) async {
    if (_conectando || _conectado) return;

    setState(() {
      _conectando = true;
      _mensaje = 'Conectando con el ESP32...';
    });

    try {
      await FlutterBluePlus.stopScan();

      await dispositivo.connect(
        license: License.nonprofit,
        timeout: const Duration(seconds: 15),
      );

      if (!mounted) {
        await dispositivo.disconnect();
        return;
      }

      _dispositivoConectado = dispositivo;

      _connectionSubscription?.cancel();

      _connectionSubscription =
          dispositivo.connectionState.listen((estado) {
            if (!mounted) return;

            if (estado == BluetoothConnectionState.disconnected) {
              _dataSubscription?.cancel();
              _dataSubscription = null;

              setState(() {
                _conectado = false;
                _conectando = false;
                _dispositivoConectado = null;
                _mensaje = 'El ESP32 se desconectó.';
              });
            }
          });

      final servicios = await dispositivo.discoverServices();

      BluetoothCharacteristic? caracteristica;

      for (final servicio in servicios) {
        if (servicio.uuid == _serviceUuid) {
          for (final elemento in servicio.characteristics) {
            if (elemento.uuid == _characteristicUuid) {
              caracteristica = elemento;
              break;
            }
          }
        }
      }

      if (caracteristica == null) {
        throw Exception(
          'El dispositivo no tiene la característica de AuraSync.',
        );
      }

      if (!caracteristica.properties.notify) {
        throw Exception(
          'La característica no admite notificaciones.',
        );
      }

      await _dataSubscription?.cancel();

      _dataSubscription = caracteristica.onValueReceived.listen(
        _procesarDatos,
      );

      await caracteristica.setNotifyValue(true);

      if (!mounted) {
        await dispositivo.disconnect();
        return;
      }

      setState(() {
        _conectado = true;
        _conectando = false;
        _mensaje = 'Conectado. Esperando datos del ESP32...';
      });
    } catch (error) {
      await _dataSubscription?.cancel();
      _dataSubscription = null;

      await _connectionSubscription?.cancel();
      _connectionSubscription = null;

      try {
        await dispositivo.disconnect();
      } catch (_) {
        // El dispositivo podría no haber llegado a conectarse.
      }

      _dispositivoConectado = null;

      if (!mounted) return;

      setState(() {
        _conectado = false;
        _conectando = false;
        _mensaje = 'No se pudo conectar: $error';
      });
    }
  }

  void _procesarDatos(List<int> bytes) {
    try {
      final texto = utf8.decode(bytes).trim();
      final partes = texto.split(',');

      if (partes.length != 2) {
        throw const FormatException('Formato incorrecto');
      }

      final ritmo = int.parse(partes[0].trim());
      final pasos = int.parse(partes[1].trim());

      if (!mounted) return;

      setState(() {
        _ritmoCardiaco = ritmo;
        _pasos = pasos;
        _mensaje = 'Datos simulados recibidos correctamente.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _mensaje = 'Se recibió un dato con formato incorrecto.';
      });
    }
  }

  Future<void> _desconectar() async {
    final dispositivo = _dispositivoConectado;

    if (dispositivo == null) return;

    try {
      await dispositivo.disconnect();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _mensaje = 'No se pudo desconectar: $error';
      });
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanningSubscription?.cancel();
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();

    FlutterBluePlus.stopScan();
    _dispositivoConectado?.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text('Conectar smartwatch'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.bluetooth_searching_rounded,
              size: 70,
              color: Color(0xFF5145CD),
            ),
            const SizedBox(height: 12),
            const Text(
              'AuraSync Watch',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Conecta el ESP32 que simula tu smartwatch.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _mensaje,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _buscando || _conectando || _conectado
                  ? null
                  : _buscarDispositivos,
              icon: const Icon(Icons.search),
              label: Text(
                _buscando ? 'Buscando...' : 'Buscar dispositivo',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5145CD),
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            if (_buscando)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (_dispositivos.isNotEmpty && !_conectado) ...[
              const Text(
                'Dispositivos compatibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._dispositivos.map((resultado) {
                final nombre =
                resultado.advertisementData.advName.isNotEmpty
                    ? resultado.advertisementData.advName
                    : 'AuraSync Watch';

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.watch),
                    title: Text(nombre),
                    subtitle: Text(
                      resultado.device.remoteId.toString(),
                    ),
                    trailing: FilledButton(
                      onPressed: _conectando
                          ? null
                          : () => _conectar(resultado.device),
                      child: const Text('Conectar'),
                    ),
                  ),
                );
              }),
            ],

            if (_conectado) ...[
              const SizedBox(height: 20),
              const Text(
                'Datos recibidos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Estos valores son simulados por el ESP32.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  title: const Text('Ritmo cardiaco'),
                  subtitle: Text(
                    _ritmoCardiaco == null
                        ? 'Esperando datos...'
                        : '$_ritmoCardiaco lpm',
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.directions_walk,
                    color: Colors.deepPurple,
                  ),
                  title: const Text('Pasos'),
                  subtitle: Text(
                    _pasos == null
                        ? 'Esperando datos...'
                        : '$_pasos pasos',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _desconectar,
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text('Desconectar'),
              ),
            ],

            const SizedBox(height: 16),

            TextButton(
              onPressed: openAppSettings,
              child: const Text(
                'Abrir configuración de permisos',
              ),
            ),
          ],
        ),
      ),
    );
  }
}