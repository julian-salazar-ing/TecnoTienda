import 'package:flutter/material.dart';
import 'modelos.dart';
import 'tienda.dart';

Future<void> formularioProducto(BuildContext context, Tienda tienda,
    [Producto? producto]) async {
  final guardado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FormularioProducto(tienda: tienda, producto: producto),
  );
  if (guardado == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado correctamente')));
  }
}

class _FormularioProducto extends StatefulWidget {
  const _FormularioProducto({required this.tienda, this.producto});
  final Tienda tienda;
  final Producto? producto;
  @override
  State<_FormularioProducto> createState() => _FormularioProductoState();
}

class _FormularioProductoState extends State<_FormularioProducto> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _sku;
  late final TextEditingController _nombre;
  late final TextEditingController _categoria;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _sku = TextEditingController(text: p?.sku ?? '');
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _categoria = TextEditingController(text: p?.categoria ?? '');
    _precio = TextEditingController(text: p?.precio.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _sku.dispose();
    _nombre.dispose();
    _categoria.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) return;
    final error = widget.tienda.guardarProducto(
      id: widget.producto?.id,
      sku: _sku.text,
      nombre: _nombre.text,
      categoria: _categoria.text,
      precio: int.parse(_precio.text.trim()),
      stock: int.parse(_stock.text.trim()),
      activo: _activo,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          18, 8, 18, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                  widget.producto == null
                      ? 'Agregar producto al catálogo'
                      : 'Actualizar producto',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final campo in [
                (_sku, 'Código SKU'),
                (_nombre, 'Nombre del producto'),
                (_categoria, 'Categoría')
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: campo.$1,
                    decoration: InputDecoration(
                        labelText: campo.$2,
                        border: const OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Campo obligatorio'
                        : null,
                  ),
                ),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: _precio,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Precio COP', border: OutlineInputBorder()),
                  validator: (v) => (int.tryParse((v ?? '').trim()) ?? 0) <= 0
                      ? 'Precio inválido'
                      : null,
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Existencias', border: OutlineInputBorder()),
                  validator: (v) => int.tryParse((v ?? '').trim()) == null ||
                          int.parse(v!.trim()) < 0
                      ? 'Stock inválido'
                      : null,
                )),
              ]),
              SwitchListTile(
                  title: const Text('Visible en catálogo'),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v)),
              const SizedBox(height: 8),
              FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar producto')),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> confirmarEliminacion(
    BuildContext context, Tienda tienda, Producto producto) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar producto'),
      content: Text(
          '¿Eliminar ${producto.nombre}? Si tiene pedidos, tendrás que desactivarlo en lugar de borrarlo.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar')),
      ],
    ),
  );
  if (confirmado != true || !context.mounted) return;
  final error = tienda.eliminarProducto(producto.id);
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(error ?? 'Producto eliminado')));
}
