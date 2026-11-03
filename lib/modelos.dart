class Producto {
  Producto(
      this.id, this.sku, this.nombre, this.categoria, this.precio, this.stock,
      {this.activo = true});
  final int id;
  String sku, nombre, categoria;
  int precio, stock;
  bool activo;
  Map<String, dynamic> toJson() => {
        'id': id,
        'sku': sku,
        'nombre': nombre,
        'categoria': categoria,
        'precio': precio,
        'stock': stock,
        'activo': activo
      };
  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
      (j['id'] as num).toInt(),
      j['sku'] as String,
      j['nombre'] as String,
      j['categoria'] as String,
      (j['precio'] as num).toInt(),
      (j['stock'] as num).toInt(),
      activo: j['activo'] as bool? ?? true);
}

class Pedido {
  Pedido(this.id, this.cliente, this.items, this.total,
      {this.estado = 'pendiente'});
  final int id;
  final String cliente;
  final Map<int, int> items;
  final int total;
  String estado;
  Map<String, dynamic> toJson() => {
        'id': id,
        'cliente': cliente,
        'items': items.map((k, v) => MapEntry('$k', v)),
        'total': total,
        'estado': estado
      };
  factory Pedido.fromJson(Map<String, dynamic> j) => Pedido(
      (j['id'] as num).toInt(),
      j['cliente'] as String,
      (j['items'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(int.parse(k), (v as num).toInt())),
      (j['total'] as num).toInt(),
      estado: j['estado'] as String? ?? 'pendiente');
}

String dinero(int valor) =>
    '\$${valor.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
