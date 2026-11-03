import 'package:flutter/material.dart';
import 'tienda.dart';
import 'modelos.dart';
import 'opciones_productos.dart';

class MisProductos extends StatefulWidget {
  const MisProductos(
      {super.key, required this.tienda, this.administrar = false});
  final Tienda tienda;
  final bool administrar;
  @override
  State<MisProductos> createState() => _MisProductosState();
}

class _MisProductosState extends State<MisProductos> {
  String busqueda = '';

  IconData _icono(String categoria) {
    final c = categoria.toLowerCase();
    if (c.contains('comput')) return Icons.laptop_mac;
    if (c.contains('audio')) return Icons.headphones;
    if (c.contains('acces')) return Icons.mouse;
    if (c.contains('monitor')) return Icons.desktop_windows;
    if (c.contains('celul')) return Icons.smartphone;
    return Icons.devices_other;
  }

  @override
  Widget build(BuildContext context) {
    final tienda = widget.tienda;
    final productos =
        tienda.buscar(busqueda, incluirInactivos: widget.administrar);
    return Scaffold(
      appBar: widget.administrar
          ? AppBar(title: const Text('Inventario · Administrador'))
          : null,
      floatingActionButton: widget.administrar
          ? FloatingActionButton.extended(
              onPressed: () => formularioProducto(context, tienda),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo producto'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.administrar)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF102A56), Color(0xFF315CC2)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TECNOTIENDA',
                      style:
                          TextStyle(color: Colors.white70, letterSpacing: 2)),
                  SizedBox(height: 8),
                  Text('Tecnología a tu alcance',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('Encuentra computadores y accesorios',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar producto, categoría o SKU',
                border: OutlineInputBorder(),
              ),
              onChanged: (texto) => setState(() => busqueda = texto),
            ),
          ),
          if (widget.administrar)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Text(
                  'Usa los botones Editar y Eliminar de cada producto. El botón + registra nuevos productos.'),
            ),
          Expanded(
            child: productos.isEmpty
                ? const Center(child: Text('No se encontraron productos'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final p = productos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EEFA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_icono(p.categoria),
                                    color: const Color(0xFF244A9B), size: 34),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    Text('${p.sku} · ${p.categoria}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(height: 5),
                                    Text(dinero(p.precio),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF244A9B))),
                                    Text(
                                        'Existencias: ${p.stock}${p.activo ? '' : ' · Inactivo'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    if (widget.administrar)
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () => formularioProducto(
                                                context, tienda, p),
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 18),
                                            label: const Text('Editar'),
                                          ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                confirmarEliminacion(
                                                    context, tienda, p),
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 18),
                                            label: const Text('Eliminar'),
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Colors.red.shade700),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              if (!widget.administrar)
                                IconButton.filledTonal(
                                  tooltip: 'Agregar al carrito',
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: p.stock >
                                          (tienda.carrito[p.id] ?? 0)
                                      ? () {
                                          tienda.agregar(p);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '${p.nombre} agregado al carrito'),
                                                duration:
                                                    const Duration(seconds: 1)),
                                          );
                                        }
                                      : null,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
