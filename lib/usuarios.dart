import 'package:flutter/material.dart';
import 'tienda.dart';

class PantallaCuenta extends StatelessWidget {
  const PantallaCuenta({
    super.key,
    required this.tienda,
    required this.abrirAdministracion,
  });

  final Tienda tienda;
  final VoidCallback abrirAdministracion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle, size: 68),
              Text(tienda.usuario == null
                  ? 'Acceso de demostración'
                  : 'Usuario: ${tienda.usuario}'),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => mostrarAcceso(context, tienda),
                child: Text(tienda.usuario == null
                    ? 'Ingresar / registrar usuario'
                    : 'Cambiar usuario'),
              ),
              if (tienda.administrador)
                FilledButton.tonal(
                  onPressed: abrirAdministracion,
                  child: const Text('Administrar productos y pedidos'),
                ),
              if (tienda.usuario != null)
                TextButton(
                  onPressed: tienda.salir,
                  child: const Text('Cerrar sesión'),
                ),
              const SizedBox(height: 12),
              const Text(
                'Prototipo académico: no utiliza contraseñas ni autenticación segura.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> mostrarAcceso(BuildContext context, Tienda tienda) async {
  final resultado = await showDialog<({String nombre, bool admin})>(
    context: context,
    builder: (_) => const _DialogoAcceso(),
  );

  if (resultado == null) return;
  tienda.ingresar(resultado.nombre, comoAdmin: resultado.admin);
}

class _DialogoAcceso extends StatefulWidget {
  const _DialogoAcceso();

  @override
  State<_DialogoAcceso> createState() => _DialogoAccesoState();
}

class _DialogoAccesoState extends State<_DialogoAcceso> {
  final TextEditingController _nombre = TextEditingController();
  bool _admin = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre de usuario')),
      );
      return;
    }
    Navigator.of(context).pop((nombre: nombre, admin: _admin));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Acceso de demostración'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombre,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _guardar(),
            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
          ),
          SwitchListTile(
            title: const Text('Simular administrador'),
            value: _admin,
            onChanged: (valor) => setState(() => _admin = valor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Entrar')),
      ],
    );
  }
}
