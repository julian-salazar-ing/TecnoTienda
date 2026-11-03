import 'package:flutter/material.dart';
import 'tienda.dart';
import 'modelos.dart';

class PantallaCarrito extends StatelessWidget {
  const PantallaCarrito({super.key, required this.tienda});
  final Tienda tienda;
  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
            child: tienda.carrito.isEmpty
                ? const Center(child: Text('Tu carrito está vacío'))
                : ListView(children: [
                    for (final e in tienda.carrito.entries)
                      if (tienda.productoPorId(e.key) != null)
                        Builder(builder: (context) {
                          final p = tienda.productoPorId(e.key)!;
                          return Card(
                              child: ListTile(
                            title: Text(p.nombre),
                            subtitle: Text('${dinero(p.precio)} × ${e.value}'),
                            trailing: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          tienda.cantidad(p, e.value - 1)),
                                  Text('${e.value}'),
                                  IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: e.value < p.stock
                                          ? () =>
                                              tienda.cantidad(p, e.value + 1)
                                          : null),
                                ]),
                          ));
                        }),
                  ])),
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Total: ${dinero(tienda.total)}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: tienda.carrito.isEmpty
                          ? null
                          : () {
                              final error = tienda.confirmarPedido();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(error ??
                                          'Pedido registrado correctamente')));
                            },
                      child: const Text('Realizar pedido')),
                ])),
      ]);
}
