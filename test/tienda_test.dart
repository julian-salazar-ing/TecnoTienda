import 'package:flutter_test/flutter_test.dart';
import 'package:tecnotienda_flutter/tienda.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('CRUD: agregar, buscar, actualizar y eliminar', () {
    final t = Tienda();
    expect(
        t.guardarProducto(
            sku: 'N-1',
            nombre: 'Cámara',
            categoria: 'Video',
            precio: 200000,
            stock: 3),
        isNull);
    final p = t.buscar('Cámara').single;
    expect(
        t.guardarProducto(
            id: p.id,
            sku: 'N-1',
            nombre: 'Cámara HD',
            categoria: 'Video',
            precio: 250000,
            stock: 4),
        isNull);
    expect(t.buscar('Cámara HD').single.precio, 250000);
    expect(t.eliminarProducto(p.id), isNull);
    expect(t.buscar('Cámara HD'), isEmpty);
  });
  test('SKU repetido no se permite', () {
    final t = Tienda();
    expect(
        t.guardarProducto(
            sku: 'TEC-001',
            nombre: 'Otro',
            categoria: 'Otros',
            precio: 100,
            stock: 1),
        isNotNull);
  });
  test('Carrito respeta existencias', () {
    final t = Tienda();
    final p = t.productos.first;
    p.stock = 1;
    t.agregar(p);
    t.agregar(p);
    expect(t.carrito[p.id], 1);
  });
  test('Pedido descuenta inventario y cancelación lo devuelve una sola vez',
      () {
    final t = Tienda();
    final p = t.productos.first;
    final antes = p.stock;
    t.ingresar('cliente');
    t.agregar(p);
    expect(t.confirmarPedido(), isNull);
    expect(p.stock, antes - 1);
    final pedido = t.pedidos.single;
    expect(t.cambiarEstado(pedido, 'cancelado'), true);
    expect(t.cambiarEstado(pedido, 'cancelado'), false);
    expect(p.stock, antes);
  });
  test('Pedido exige usuario', () {
    final t = Tienda();
    t.agregar(t.productos.first);
    expect(t.confirmarPedido(), isNotNull);
  });
}
