import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Stream para escuchar cambios de conectividad
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // Verificar si hay conexión a internet
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (e) {
      return false;
    }
  }

  // Verificar el tipo de conexión
  Future<List<ConnectivityResult>> getConnectionType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return [ConnectivityResult.none];
    }
  }

  // Helper privado para determinar si está conectado
  bool _isConnected(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
  }

  // Obtener estado de conexión como string
  Future<String> getConnectionStatus() async {
    final results = await getConnectionType();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return 'Sin conexión';
    }
    
    final result = results.first;
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.none:
        return 'Sin conexión';
      default:
        return 'Desconocido';
    }
  }

  // Stream controller para notificar cambios
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  void initialize() {
    _connectivity.onConnectivityChanged.listen((result) {
      _connectionStatusController.add(_isConnected(result));
    });
  }

  void dispose() {
    _connectionStatusController.close();
  }
}

// Provider para usar con Provider package
class ConnectivityProvider {
  final ConnectivityService _service = ConnectivityService();
  bool _isOnline = true;
  
  bool get isOnline => _isOnline;
  
  ConnectivityProvider() {
    _initConnectivity();
    _service.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
    });
  }
  
  Future<void> _initConnectivity() async {
    _isOnline = await _service.hasConnection();
  }
  
  Future<void> checkConnection() async {
    _isOnline = await _service.hasConnection();
  }
}