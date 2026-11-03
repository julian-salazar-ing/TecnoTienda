import 'package:flutter/material.dart';
import 'tienda.dart';
import 'misproductos.dart';
import 'carrito.dart';
import 'pedidos.dart';
import 'usuarios.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TecnoTiendaApp());
}

class TecnoTiendaApp extends StatefulWidget {
  const TecnoTiendaApp({super.key});
  @override
  State<TecnoTiendaApp> createState() => _TecnoTiendaAppState();
}

class _TecnoTiendaAppState extends State<TecnoTiendaApp> {
  final tienda = Tienda();
  @override
  void initState() {
    super.initState();
    tienda.cargar();
  }

  @override
  void dispose() {
    tienda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: tienda,
      builder: (context, _) => MaterialApp(
            title: 'TecnoTienda',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: const Color(0xFF244A9B)),
                scaffoldBackgroundColor: const Color(0xFFF7F9FE),
                useMaterial3: true),
            home: tienda.cargando
                ? const Scaffold(
                    body: Center(child: CircularProgressIndicator()))
                : Inicio(tienda: tienda),
          ));
}

class Inicio extends StatefulWidget {
  const Inicio({super.key, required this.tienda});
  final Tienda tienda;
  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int pagina = 0;
  @override
  Widget build(BuildContext context) {
    final tienda = widget.tienda;
    final paginas = [
      MisProductos(tienda: tienda),
      PantallaCarrito(tienda: tienda),
      PantallaPedidos(tienda: tienda),
      PantallaCuenta(
          tienda: tienda,
          abrirAdministracion: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => Administracion(tienda: tienda)));
          }),
    ];
    return Scaffold(
      appBar: AppBar(
          title: const Text('TecnoTienda',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            if (tienda.usuario != null)
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(child: Text(tienda.usuario!)))
          ]),
      body: paginas[pagina],
      bottomNavigationBar: NavigationBar(
          selectedIndex: pagina,
          onDestinationSelected: (i) => setState(() => pagina = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.store), label: 'Catálogo'),
            NavigationDestination(
                icon: Icon(Icons.shopping_cart), label: 'Carrito'),
            NavigationDestination(
                icon: Icon(Icons.receipt_long), label: 'Pedidos'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Cuenta'),
          ]),
    );
  }
}

class Administracion extends StatelessWidget {
  const Administracion({super.key, required this.tienda});
  final Tienda tienda;
  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Panel de administración'),
            bottom: const TabBar(
                tabs: [Tab(text: 'Productos'), Tab(text: 'Pedidos')])),
        body: TabBarView(children: [
          MisProductos(tienda: tienda, administrar: true),
          PantallaPedidos(tienda: tienda, administrar: true)
        ]),
      ));
}
