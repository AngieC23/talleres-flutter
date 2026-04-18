import 'dart:async';
import 'package:flutter/foundation.dart';

class SimulatedDataService {
  void _logInfo(String message) {
    if (kDebugMode) {
      print('🔄 DataService: $message');
    }
  }

  void _logWait(String message) {
    if (kDebugMode) {
      print('⏱ DataService: $message');
    }
  }

  void _logSuccess(String message) {
    if (kDebugMode) {
      print('✅ DataService: $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('❌ DataService: $message');
    }
  }

  Future<List<String>> fetchUsers() async {
    _logInfo('Iniciando consulta de usuarios...');
    _logWait('Esperando 2 segundos...');

    await Future.delayed(const Duration(seconds: 2));

    _logSuccess('Consulta de usuarios completada exito');

    return const [
      'Juan Perez',
      'Ana Garcia',
      'Carlos Lopez',
      'Maria Rodriguez',
      'Pedro Martinez',
      'Sofia Gonzalez',
      'Luis Hernandez',
      'Laura Diaz',
    ];
  }

  Future<List<String>> fetchProducts() async {
    _logInfo('Iniciando consulta de productos...');
    _logWait('Esperando 3 segundos...');

    await Future.delayed(const Duration(seconds: 3));

    _logSuccess('Consulta de productos completada exito');

    return const [
      'Laptop HP',
      'Mouse Logitech',
      'Teclado Mecanico',
      'Monitor Samsung',
      'Audifonos Sony',
      'Webcam Logitech',
    ];
  }

  Future<void> fetchWithError() async {
    _logInfo('Iniciando consulta con error simulado...');
    _logWait('Esperando 2 segundos...');

    await Future.delayed(const Duration(seconds: 2));

    _logError('Consulta fallo: servidor no disponible');
    throw Exception('Error simulado: El servidor no esta disponible');
  }

  Future<({List<String> users, List<String> products})> fetchConcurrentData() async {
    _logInfo('Iniciando multiples consultas concurrentes...');

    final results = await Future.wait([
      fetchUsers(),
      fetchProducts(),
    ]);

    _logSuccess('Consultas concurrentes completadas');

    return (
      users: results[0],
      products: results[1],
    );
  }
}
