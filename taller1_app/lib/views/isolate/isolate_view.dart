import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/base_view.dart';

enum TaskStatus { idle, running, success, error }

enum TaskType { fibonacci, primes }

class HeavyTask {
  HeavyTask({
    required this.type,
    required this.title,
    required this.description,
  });

  final TaskType type;
  final String title;
  final String description;
  TaskStatus status = TaskStatus.idle;
  int? elapsedMs;
  String? result;
  String? error;
}

class IsolateView extends StatefulWidget {
  const IsolateView({super.key});

  @override
  State<IsolateView> createState() => _IsolateViewState();
}

class _IsolateViewState extends State<IsolateView> {
  final List<HeavyTask> _tasks = [
    HeavyTask(
      type: TaskType.fibonacci,
      title: 'Fibonacci',
      description: 'Calcula Fibonacci(35) usando recursion',
    ),
    HeavyTask(
      type: TaskType.primes,
      title: 'Numeros Primos',
      description: 'Encuentra primos hasta 100,000',
    ),
  ];

  bool get _hasRunning =>
      _tasks.any((task) => task.status == TaskStatus.running);

  void _log(String message) {
    if (kDebugMode) {
      print('🧵 IsolateController: $message');
    }
  }

  int get _completed =>
      _tasks.where((task) => task.status == TaskStatus.success).length;

  int get _running =>
      _tasks.where((task) => task.status == TaskStatus.running).length;

  int get _errors =>
      _tasks.where((task) => task.status == TaskStatus.error).length;

  int get _totalMs => _tasks
      .where(
        (task) => task.status == TaskStatus.success && task.elapsedMs != null,
      )
      .fold(0, (sum, task) => sum + task.elapsedMs!);

  int get _avgMs {
    final done = _tasks.where(
      (task) => task.status == TaskStatus.success && task.elapsedMs != null,
    );
    if (done.isEmpty) return 0;
    return _totalMs ~/ done.length;
  }

  Future<void> _runAllParallel() async {
    if (_hasRunning) return;
    _log('Iniciando ejecucion paralela de todas las tareas');
    await Future.wait(_tasks.map(_runTask));
    _log('Ejecucion paralela finalizada');
  }

  void _resetAll() {
    if (_hasRunning) return;
    _log('Reiniciando estado de todas las tareas');
    setState(() {
      for (final task in _tasks) {
        task.status = TaskStatus.idle;
        task.elapsedMs = null;
        task.result = null;
        task.error = null;
      }
    });
  }

  Future<void> _runTask(HeavyTask task) async {
    if (task.status == TaskStatus.running) return;

    _log('Iniciando tarea ${task.title}');

    setState(() {
      task.status = TaskStatus.running;
      task.error = null;
      task.result = null;
      task.elapsedMs = null;
    });

    final stopwatch = Stopwatch()..start();

    try {
      final output = await _executeTaskInIsolate(task.type);
      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        task.status = TaskStatus.success;
        task.elapsedMs = stopwatch.elapsedMilliseconds;
        task.result = output;
      });
      _log(
        'Tarea ${task.title} completada en ${stopwatch.elapsedMilliseconds}ms',
      );
    } catch (e) {
      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        task.status = TaskStatus.error;
        task.elapsedMs = stopwatch.elapsedMilliseconds;
        task.error = e.toString();
      });
      _log('Error en tarea ${task.title}: $e');
    }
  }

  Future<String> _executeTaskInIsolate(TaskType type) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(_isolateEntryPoint, {
      'sendPort': receivePort.sendPort,
      'task': type.name,
    });

    final response = await receivePort.first as Map<String, dynamic>;

    if (response['ok'] == true) {
      return response['result'] as String;
    }

    throw Exception(response['error'] as String);
  }

  static void _isolateEntryPoint(Map<String, dynamic> message) {
    final sendPort = message['sendPort'] as SendPort;
    final task = message['task'] as String;

    try {
      if (task == TaskType.fibonacci.name) {
        final value = _fibonacci(35);
        if (kDebugMode) {
          print('✅ IsolateWorker: Fibonacci completo -> $value');
        }
        sendPort.send({'ok': true, 'result': 'Fibonacci(35) = $value'});
        return;
      }

      if (task == TaskType.primes.name) {
        final count = _countPrimes(100000);
        if (kDebugMode) {
          print('✅ IsolateWorker: Primos completos -> $count');
        }
        sendPort.send({
          'ok': true,
          'result': 'Encontrados $count numeros primos',
        });
        return;
      }

      sendPort.send({'ok': false, 'error': 'Tarea desconocida'});
    } catch (e) {
      sendPort.send({'ok': false, 'error': e.toString()});
    }
  }

  static int _fibonacci(int n) {
    if (n <= 1) return n;
    return _fibonacci(n - 1) + _fibonacci(n - 2);
  }

  static int _countPrimes(int max) {
    var count = 0;
    for (var n = 2; n <= max; n++) {
      var isPrime = true;
      for (var i = 2; i * i <= n; i++) {
        if (n % i == 0) {
          isPrime = false;
          break;
        }
      }
      if (isPrime) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Isolates - Tareas Pesadas',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoCard(),
            const SizedBox(height: 12),
            _statsCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _hasRunning ? null : _runAllParallel,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Ejecutar Todo en Paralelo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFFF44336),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _hasRunning ? null : _resetAll,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar Todo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              '🎯 Tareas Disponibles',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._tasks.map(_taskCard),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚒ Demo de Isolates en Flutter',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          SizedBox(height: 8),
          Text('· Cada tarea se ejecuta en un isolate separado'),
          Text('· No bloquea el hilo principal (UI)'),
          Text('· Comunicacion por SendPort/ReceivePort'),
          Text('· Multiples isolates pueden correr en paralelo'),
          Text('· Revisa la consola para logs detallados'),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBED6EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Estadisticas de Rendimiento',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statItem('$_completed', 'Completadas', const Color(0xFF4CAF50)),
              _statItem('$_running', 'Ejecutando', const Color(0xFFFF9800)),
              _statItem('$_errors', 'Errores', const Color(0xFFF44336)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _statItem(
                '${_totalMs}ms',
                'Tiempo Total',
                const Color(0xFF9C27B0),
              ),
              _statItem('${_avgMs}ms', 'Promedio', const Color(0xFF3F51B5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _taskCard(HeavyTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6D8D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42B857),
                  foregroundColor: Colors.white,
                ),
                onPressed: task.status == TaskStatus.running
                    ? null
                    : () => _runTask(task),
                child: const Text('Ejecutar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Estado: ${_statusText(task.status)}'),
          if (task.elapsedMs != null) Text('Tiempo: ${task.elapsedMs}ms'),
          if (task.result != null) Text('Resultado: ${task.result}'),
          if (task.error != null)
            Text(
              'Error: ${task.error}',
              style: const TextStyle(color: Color(0xFFF44336)),
            ),
        ],
      ),
    );
  }

  String _statusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.idle:
        return 'Pendiente';
      case TaskStatus.running:
        return 'Ejecutando...';
      case TaskStatus.success:
        return 'Completada';
      case TaskStatus.error:
        return 'Con error';
    }
  }
}
