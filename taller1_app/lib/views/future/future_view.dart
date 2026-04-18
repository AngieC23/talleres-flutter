import 'package:flutter/material.dart';
import 'package:taller1_app/services/simulated_data_service.dart';

import '../../widgets/base_view.dart';

enum RequestState { idle, loading, success, error }

class FutureView extends StatefulWidget {
  const FutureView({super.key});

  @override
  State<FutureView> createState() => _FutureViewState();
}

class _FutureViewState extends State<FutureView> {
  final SimulatedDataService _service = SimulatedDataService();

  RequestState _usersState = RequestState.idle;
  RequestState _productsState = RequestState.idle;
  RequestState _errorState = RequestState.idle;
  RequestState _concurrentState = RequestState.idle;

  List<String> _users = [];
  List<String> _products = [];
  List<String> _concurrentUsers = [];
  List<String> _concurrentProducts = [];
  String _errorMessage = '';

  Future<void> _loadUsers() async {
    setState(() {
      _usersState = RequestState.loading;
      _users = [];
    });

    try {
      final users = await _service.fetchUsers();
      if (!mounted) return;
      setState(() {
        _usersState = RequestState.success;
        _users = users;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _usersState = RequestState.error;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _productsState = RequestState.loading;
      _products = [];
    });

    try {
      final products = await _service.fetchProducts();
      if (!mounted) return;
      setState(() {
        _productsState = RequestState.success;
        _products = products;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _productsState = RequestState.error;
      });
    }
  }

  Future<void> _triggerError() async {
    setState(() {
      _errorState = RequestState.loading;
      _errorMessage = '';
    });

    try {
      await _service.fetchWithError();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorState = RequestState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _runConcurrent() async {
    setState(() {
      _concurrentState = RequestState.loading;
      _concurrentUsers = [];
      _concurrentProducts = [];
    });

    try {
      final result = await _service.fetchConcurrentData();
      if (!mounted) return;
      setState(() {
        _concurrentState = RequestState.success;
        _concurrentUsers = result.users;
        _concurrentProducts = result.products;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _concurrentState = RequestState.error;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _usersState = RequestState.idle;
      _productsState = RequestState.idle;
      _errorState = RequestState.idle;
      _concurrentState = RequestState.idle;
      _users = [];
      _products = [];
      _concurrentUsers = [];
      _concurrentProducts = [];
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Future / Async / Await Demo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 14),
            _buildButtonRows(),
            const SizedBox(height: 14),
            _buildUsersCard(),
            const SizedBox(height: 12),
            _buildProductsCard(),
            const SizedBox(height: 12),
            _buildErrorCard(),
            const SizedBox(height: 12),
            _buildConcurrentCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Demo de Asincronia en Flutter',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1660B8),
            ),
          ),
          SizedBox(height: 8),
          Text('· Cada boton simula una consulta con Future.delayed (2-3s)'),
          Text('· Usa async/await sin bloquear la UI'),
          Text('· Muestra estados: Cargando / Exito / Error'),
          Text('· Revisa la consola para ver el orden de ejecucion'),
        ],
      ),
    );
  }

  Widget _buildButtonRows() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                text: 'Cargar Usuarios',
                icon: Icons.people,
                color: const Color(0xFF4CAF50),
                onTap: _loadUsers,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                text: 'Cargar Productos',
                icon: Icons.inventory_2,
                color: const Color(0xFFFF9800),
                onTap: _loadProducts,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                text: 'Provocar Error',
                icon: Icons.error,
                color: const Color(0xFFF44336),
                onTap: _triggerError,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                text: 'Consultas Concurrentes',
                icon: Icons.sync,
                color: const Color(0xFF9C27B0),
                onTap: _runConcurrent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB0B0B0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _clearAll,
            icon: const Icon(Icons.clear),
            label: const Text('Limpiar Resultados'),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }

  Widget _buildUsersCard() {
    return _resultCard(
      title: '👥 Usuarios',
      body: _stateContent(
        state: _usersState,
        success: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ Datos cargados (${_users.length} elementos):',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ..._users.map((user) => Text('· $user')),
          ],
        ),
        loadingText: 'Cargando usuarios...',
      ),
    );
  }

  Widget _buildProductsCard() {
    return _resultCard(
      title: '📦 Productos',
      body: _stateContent(
        state: _productsState,
        success: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ Datos cargados (${_products.length} elementos):',
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ..._products.map((product) => Text('· $product')),
          ],
        ),
        loadingText: 'Cargando productos...',
      ),
    );
  }

  Widget _buildErrorCard() {
    final body = _errorState == RequestState.idle
        ? const Text('Presiona el boton para simular error')
        : _stateContent(
            state: _errorState,
            success: const SizedBox.shrink(),
            loadingText: 'Simulando error...',
            errorText: _errorMessage,
          );

    return _resultCard(title: '💥 Error Simulado', body: body);
  }

  Widget _buildConcurrentCard() {
    return _resultCard(
      title: '🌐 Consultas Concurrentes',
      body: _stateContent(
        state: _concurrentState,
        success: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Todas las consultas completadas:',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('USUARIOS:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ..._concurrentUsers.map((user) => Text('· $user')),
            const SizedBox(height: 10),
            const Text('PRODUCTOS:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ..._concurrentProducts.map((product) => Text('· $product')),
          ],
        ),
        loadingText: 'Ejecutando consultas en paralelo...',
      ),
    );
  }

  Widget _stateContent({
    required RequestState state,
    required Widget success,
    required String loadingText,
    String errorText = 'Ocurrio un error',
  }) {
    if (state == RequestState.loading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(loadingText),
        ],
      );
    }

    if (state == RequestState.error) {
      return Text(
        '❌ Error: $errorText',
        style: const TextStyle(color: Color(0xFFF44336)),
      );
    }

    if (state == RequestState.success) {
      return success;
    }

    return const Text('Presiona el boton para cargar datos');
  }

  Widget _resultCard({required String title, required Widget body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DADA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}
