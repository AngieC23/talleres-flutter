import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 212, 66, 181),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _appBarTitle = "Hola, Flutter";
  bool _isChanged = false;
  int _counter = 0;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeTitle() {
    setState(() {
      _appBarTitle = "¡Título cambiado!";
      _isChanged = true;
    });
    _showSnackBar("Título actualizado");
  }

  void _resetTitle() {
    setState(() {
      _appBarTitle = "Hola, Flutter";
      _isChanged = false;
    });
    _showSnackBar("Título actualizado");
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Anterior',
          onPressed: _isChanged ? _resetTitle : null,
        ),
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Siguiente',
            onPressed: !_isChanged ? _changeTitle : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Nombre del estudiante
              const Text(
                'Angie Tatiana Cardenas',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Imágenes debajo del nombre
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMmgQrXpV3pBMbP-MneICwgas4WnNkgPFf-g&s',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Contador en container rosa
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE4EC),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    const Text('You have pushed the button this many times:'),
                    const SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stack: texto sobre imagen
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(
                    color: Color.fromARGB(255, 212, 66, 181),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      'https://miro.medium.com/max/2000/1*v61-QL8UkB1OGUdBpFCQqQ.png',
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      width: double.infinity,
                      height: 120,
                    ),
                    const Text(
                      'Flutter Logo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ListView de 4 elementos con icono y texto
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Color.fromARGB(255, 212, 66, 181),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    ListTile(
                      leading: Icon(Icons.storm, color: Colors.purple),
                      title: Text('Clase 1'),
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite, color: Colors.pink),
                      title: Text('Clase 2'),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.orange,
                      ),
                      title: Text('Clase 3'),
                    ),
                    ListTile(
                      leading: Icon(Icons.code, color: Colors.blue),
                      title: Text('Clase 4'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
