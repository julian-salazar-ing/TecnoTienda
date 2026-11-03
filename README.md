# TecnoTienda Flutter — Evidencia GA8

## Archivos Dart
- `main.dart`: inicio, navegación y administración.
- `misproductos.dart`: búsqueda y listado con `ListView.builder`, `Card` y `ListTile`.
- `opciones_productos.dart`: agregar y actualizar con `showModalBottomSheet`; eliminar con `AlertDialog`.
- `modelos.dart`: Producto y Pedido.
- `tienda.dart`: reglas de negocio, CRUD, carrito, pedidos y persistencia con `shared_preferences`.
- `carrito.dart`, `pedidos.dart`, `usuarios.dart`: pantallas restantes.

## Instalación en VS Code / PowerShell
1. Hacer copia de seguridad del proyecto anterior.
2. Copiar `lib/`, `test/` y `pubspec.yaml` del ZIP en la carpeta del proyecto Flutter, reemplazando los archivos anteriores.
3. Ejecutar `flutter pub get`.
4. Ejecutar `dart format lib test`.
5. Ejecutar `flutter analyze`.
6. Ejecutar `flutter test`.
7. Ejecutar `flutter run -d chrome`.
8. Si aún no existe la carpeta `web`, ejecutar `flutter create --platforms=web .` antes de `flutter run`.

## Uso
- Catálogo: buscar y agregar al carrito.
- Cuenta: ingresar usuario de demostración; activar «Simular administrador» para probar el CRUD.
- Administración: agregar con botón +, editar tocando producto y eliminar con pulsación larga o menú.
- Los datos se guardan localmente con `shared_preferences` y se recuperan al recargar la página.
- Para probar persistencia, crear producto/pedido, recargar Chrome y verificar que permanezca.

## Advertencias
- Es un prototipo educativo, sin contraseñas ni permisos reales. No se debe publicar como tienda operativa.
- El almacenamiento local no sincroniza entre navegadores ni teléfonos, no es una base de datos central.
- `shared_preferences` es adecuado para prototipos pequeños, no para transacciones comerciales críticas.
- La compilación Android requiere configurar el SDK de Android posteriormente.
- El código debe probarse en el PC del aprendiz; en el entorno de creación no está disponible Flutter SDK para compilarlo.
