import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modelos.dart';

class Tienda extends ChangeNotifier {
  final productos = <Producto>[
    Producto(1, 'TEC-001', 'Portátil 14 pulgadas', 'Computadores', 1850000, 8),
    Producto(2, 'TEC-002', 'Mouse inalámbrico', 'Accesorios', 55000, 20),
    Producto(3, 'TEC-003', 'Teclado mecánico', 'Accesorios', 175000, 12),
    Producto(4, 'TEC-004', 'Audífonos Bluetooth', 'Audio', 120000, 15),
  ];
  final carrito = <int, int>{};
  final pedidos = <Pedido>[];
  String? usuario;
  bool administrador = false;
  bool cargando = true;
  SharedPreferences? _prefs;

  Future<void> cargar() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString('tecnotienda_v1');
      if (raw != null) {
        final datos = jsonDecode(raw) as Map<String, dynamic>;
        productos
          ..clear()
          ..addAll((datos['productos'] as List).map(
              (e) => Producto.fromJson(Map<String, dynamic>.from(e as Map))));
        pedidos
          ..clear()
          ..addAll((datos['pedidos'] as List).map(
              (e) => Pedido.fromJson(Map<String, dynamic>.from(e as Map))));
        carrito
          ..clear()
          ..addAll((datos['carrito'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(int.parse(k), (v as num).toInt())));
        usuario = datos['usuario'] as String?;
        // El privilegio de administrador NO se restaura automáticamente.
        administrador = false;
      }
    } catch (e) {
      debugPrint('No se pudo recuperar almacenamiento local: $e');
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> _guardar() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(
          'tecnotienda_v1',
          jsonEncode({
            'productos': productos.map((e) => e.toJson()).toList(),
            'pedidos': pedidos.map((e) => e.toJson()).toList(),
            'carrito': carrito.map((k, v) => MapEntry('$k', v)),
            'usuario': usuario,
          }));
    } catch (e) {
      debugPrint('Error guardando datos: $e');
    }
  }

  void _cambio() {
    notifyListeners();
    _guardar();
  }

  int get total => carrito.entries.fold(0, (s, e) {
        final p = productoPorId(e.key);
        return s + (p?.precio ?? 0) * e.value;
      });
  Producto? productoPorId(int id) {
    for (final p in productos) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Producto> buscar(String texto, {bool incluirInactivos = false}) {
    final q = texto.trim().toLowerCase();
    return productos
        .where((p) =>
            (incluirInactivos || p.activo) &&
            '${p.nombre} ${p.categoria} ${p.sku}'.toLowerCase().contains(q))
        .toList();
  }

  void ingresar(String nombre, {bool comoAdmin = false}) {
    if (nombre.trim().isEmpty) return;
    usuario = nombre.trim();
    administrador = comoAdmin;
    _cambio();
  }

  void salir() {
    usuario = null;
    administrador = false;
    _cambio();
  }

  String? guardarProducto(
      {int? id,
      required String sku,
      required String nombre,
      required String categoria,
      required int precio,
      required int stock,
      bool activo = true}) {
    sku = sku.trim();
    nombre = nombre.trim();
    categoria = categoria.trim();
    if (sku.isEmpty ||
        nombre.isEmpty ||
        categoria.isEmpty ||
        precio <= 0 ||
        stock < 0) return 'Revisa los datos del producto';
    if (productos
        .any((p) => p.sku.toLowerCase() == sku.toLowerCase() && p.id != id))
      return 'El código SKU ya existe';
    if (id == null) {
      final nuevoId = productos.fold<int>(0, (a, p) => p.id > a ? p.id : a) + 1;
      productos.add(Producto(nuevoId, sku, nombre, categoria, precio, stock,
          activo: activo));
    } else {
      final p = productoPorId(id);
      if (p == null) return 'Producto no encontrado';
      if (stock < (carrito[id] ?? 0))
        return 'El stock es menor a lo reservado en el carrito';
      if (!activo && (carrito[id] ?? 0) > 0)
        return 'Quita primero el producto del carrito';
      p.sku = sku;
      p.nombre = nombre;
      p.categoria = categoria;
      p.precio = precio;
      p.stock = stock;
      p.activo = activo;
    }
    _cambio();
    return null;
  }

  String? eliminarProducto(int id) {
    if (carrito.containsKey(id))
      return 'Primero retira el producto del carrito';
    if (pedidos.any((o) => o.items.containsKey(id)))
      return 'El producto tiene pedidos: desactívalo en lugar de eliminarlo';
    productos.removeWhere((p) => p.id == id);
    _cambio();
    return null;
  }

  void agregar(Producto p) {
    if (!p.activo || p.stock <= (carrito[p.id] ?? 0)) return;
    carrito[p.id] = (carrito[p.id] ?? 0) + 1;
    _cambio();
  }

  void cantidad(Producto p, int n) {
    if (n <= 0) {
      carrito.remove(p.id);
    } else if (p.activo && n <= p.stock) {
      carrito[p.id] = n;
    }
    _cambio();
  }

  String? confirmarPedido() {
    if (usuario == null) return 'Debes ingresar con un usuario';
    if (carrito.isEmpty) return 'El carrito está vacío';
    for (final e in carrito.entries) {
      final p = productoPorId(e.key);
      if (p == null || !p.activo || e.value > p.stock)
        return 'No hay existencias suficientes';
    }
    final items = Map<int, int>.from(carrito);
    final valor = total;
    for (final e in items.entries) {
      productoPorId(e.key)!.stock -= e.value;
    }
    final id = pedidos.fold<int>(0, (a, o) => o.id > a ? o.id : a) + 1;
    pedidos.add(Pedido(id, usuario!, items, valor));
    carrito.clear();
    _cambio();
    return null;
  }

  bool cambiarEstado(Pedido pedido, String nuevo) {
    const permitidos = {
      'pendiente': ['confirmado', 'cancelado'],
      'confirmado': ['enviado', 'cancelado']
    };
    if (!(permitidos[pedido.estado] ?? []).contains(nuevo)) return false;
    if (nuevo == 'cancelado') {
      for (final e in pedido.items.entries) {
        final p = productoPorId(e.key);
        if (p != null) p.stock += e.value;
      }
    }
    pedido.estado = nuevo;
    _cambio();
    return true;
  }
}
