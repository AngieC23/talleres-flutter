import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/base_view.dart';

enum TimerState { stopped, running, paused }

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Timer? _timer;
  int _elapsedMs = 0;
  bool _isRunning = false;
  TimerState _timerState = TimerState.stopped;

  void _log(String message) {
    if (kDebugMode) {
      print('🔄 StopwatchController: $message');
    }
  }

  void _changeState(TimerState newState) {
    final previous = _timerState;
    _timerState = newState;
    _log('Estado cambio de $previous a $newState');
  }

  void _start() {
    if (_isRunning) return;
    _timer?.cancel();

    _log('Usuario presiono INICIAR');

    setState(() {
      _isRunning = true;
    });
    _changeState(TimerState.running);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedMs += 100;
      });
      _log('Tiempo actual -> ${_formatDigital(_elapsedMs)}');
    });
  }

  void _pauseOrResume() {
    if (_isRunning) {
      _log('Usuario presiono PAUSAR');
      _log('Pausando cronometro...');
      _timer?.cancel();
      _log('Cancelando timer');
      setState(() {
        _isRunning = false;
      });
      _changeState(TimerState.paused);
      _log('Cronometro pausado en ${_formatDigital(_elapsedMs)}');
      return;
    }

    if (_elapsedMs == 0) return;

    _log('Usuario presiono REANUDAR');
    _log('Reanudando cronometro...');

    setState(() {
      _isRunning = true;
    });
    _changeState(TimerState.running);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedMs += 100;
      });
      _log('Tiempo actual -> ${_formatDigital(_elapsedMs)}');
    });
  }

  void _reset() {
    _log('Usuario presiono REINICIAR');
    _timer?.cancel();
    _log('Cancelando timer');
    setState(() {
      _elapsedMs = 0;
      _isRunning = false;
    });
    _changeState(TimerState.stopped);
    _log('Cronometro reiniciado a ${_formatDigital(_elapsedMs)}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _log('dispose() -> timer cancelado');
    super.dispose();
  }

  String _formatDigital(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    final centiseconds = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$secs.$centiseconds';
  }

  String _formatSimple(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final canPause = _isRunning || _elapsedMs > 0;

    return BaseView(
      title: 'Cronometro - Timer Demo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(),
            const SizedBox(height: 16),
            _displayCard(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    text: 'INICIAR',
                    icon: Icons.play_arrow,
                    color: const Color(0xFF40B857),
                    onPressed: _isRunning ? null : _start,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    text: _isRunning ? 'PAUSAR' : 'REANUDAR',
                    icon: _isRunning ? Icons.pause : Icons.play_circle,
                    color: const Color(0xFFFF9800),
                    onPressed: canPause ? _pauseOrResume : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    text: 'REINICIAR',
                    icon: Icons.stop,
                    color: const Color(0xFFF44336),
                    onPressed: _reset,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⏱ Demo de Timer en Flutter',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1660B8),
            ),
          ),
          SizedBox(height: 8),
          Text('· Timer.periodic actualiza cada 100ms'),
          Text('· Manejo completo de estados: parado/corriendo/pausado'),
          Text('· Limpieza automatica de recursos'),
          Text('· Revisa la consola para logs detallados'),
        ],
      ),
    );
  }

  Widget _displayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF45474D)),
      ),
      child: Column(
        children: [
          Text(
            _isRunning ? '● CORRIENDO' : '● DETENIDO',
            style: TextStyle(
              color: _isRunning
                  ? const Color(0xFF59D36B)
                  : const Color(0xFF858A92),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDigital(_elapsedMs),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Simple: ${_formatSimple(_elapsedMs)}',
            style: const TextStyle(color: Color(0xFFBDBDBD), letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    Color foreground = Colors.white,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: color,
        disabledBackgroundColor: color,
        foregroundColor: foreground,
        disabledForegroundColor: foreground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
