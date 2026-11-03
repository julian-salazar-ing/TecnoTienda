import 'package:flutter/material.dart';
import 'tienda.dart';
import 'modelos.dart';

class PantallaPedidos extends StatelessWidget {
  const PantallaPedidos(
      {super.key, required this.tienda, this.administrar = false});
  final Tienda tienda;
  final bool administrar;
  @override
  Widget build(BuildContext context) {
    final lista = tienda.pedidos
        .where((p) => administrar || p.cliente == tienda.usuario)
        .toList();
    return ListView(children: [
      if (!administrar && tienda.usuario == null)
        const ListTile(title: Text('Ingresa en Cuenta para ver tus pedidos')),
      if (lista.isEmpty)
        const ListTile(title: Text('No hay pedidos registrados')),
      for (final pedido in lista)
        Card(
            child: ListTile(
          title: Text('Pedido #${pedido.id} · ${dinero(pedido.total)}'),
          subtitle: Text(
              '${pedido.cliente} · ${pedido.estado} · ${pedido.items.values.fold<int>(0, (a, b) => a + b)} unidades'),
          trailing: administrar
              ? PopupMenuButton<String>(
                  onSelected: (nuevo) {
                    if (!tienda.cambiarEstado(pedido, nuevo))
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cambio no permitido')));
                  },
                  itemBuilder: (_) => (pedido.estado == 'pendiente'
                          ? ['confirmado', 'cancelado']
                          : pedido.estado == 'confirmado'
                              ? ['enviado', 'cancelado']
                              : <String>[])
                      .map((v) => PopupMenuItem(value: v, child: Text(v)))
                      .toList())
              : null,
        )),
    ]);
  }
}
