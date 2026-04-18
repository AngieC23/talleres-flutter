import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Widget _item(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, const Color(0xFF9A6E86)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, color: Color(0xFF2AA86A), size: 26),
                ),
                SizedBox(height: 10),
                Text(
                  'Flutter UCEVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Taller Moviles',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'Navegacion Principal',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          _item(
            context,
            title: 'Inicio',
            subtitle: '',
            icon: Icons.home,
            iconColor: Colors.blue,
            route: '/',
          ),
          _item(
            context,
            title: 'Paso de Parametros',
            subtitle: 'Navegacion con datos',
            icon: Icons.alt_route,
            iconColor: Colors.blueAccent,
            route: '/paso_parametros',
          ),
          _item(
            context,
            title: 'Ciclo de Vida',
            subtitle: 'Estados del widget',
            icon: Icons.history_toggle_off,
            iconColor: Colors.green,
            route: '/ciclo_vida',
          ),
          _item(
            context,
            title: 'Demo de Widgets',
            subtitle: 'Componentes UI',
            icon: Icons.grid_view,
            iconColor: Colors.purple,
            route: '/',
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Text(
              'Funcionalidades Avanzadas',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          _item(
            context,
            title: 'Future',
            subtitle: 'Asincronia y estados',
            icon: Icons.schedule,
            iconColor: Colors.orange,
            route: '/future',
          ),
          _item(
            context,
            title: 'Timer',
            subtitle: 'Timer y ciclo de vida',
            icon: Icons.timer,
            iconColor: Colors.red,
            route: '/timer',
          ),
          _item(
            context,
            title: 'Isolate',
            subtitle: 'Tareas en paralelo',
            icon: Icons.memory,
            iconColor: Colors.indigo,
            route: '/isolate',
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taller de Flutter',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('Desarrollo Movil · UCEVA', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),
                Text('Flutter & Dart', style: TextStyle(color: Colors.black45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
