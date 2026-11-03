# Trazabilidad y pendientes de evidencia móvil

Origen: prototipo web TecnoTienda (Python/Flask, SQLite), con requisitos RF01-RF10 y HU01-HU06.

| Módulo | Estado Flutter inicial | Pendiente para entrega completa |
|---|---|---|
| RF01 Catálogo/búsqueda | Demo local | API y detalle de producto |
| RF02 Registro | No implementado | Registro real y validaciones de servidor |
| RF03 Autenticación | Solo simulación | Hash, tokens, sesiones y roles verificados en servidor |
| RF04 Carrito | Demo local | Persistencia y sincronización |
| RF05 Confirmar pedido | Simulación en memoria | Transacciones de backend, stock concurrente |
| RF06 Pedidos propios | Filtro local demo | Autorización en servidor |
| RF07 Administrar productos | Edición local demo | CRUD protegido en backend |
| RF08 Estados | Reglas locales demo | Validación y reversión transaccional en servidor |
| RF09 Panel admin | Pantalla demo | Métricas y backend protegido |
| RF10 Inicialización | Datos semilla en memoria | Semillas del backend |

## Diagramas de referencia (para elaborar formalmente)
- Clases: Product, Order, Store, Home, AdminPage; objetivo: ProductRepository, AuthRepository, CartService, OrderService.
- Paquetes: lib/features/catalog, auth, cart, orders, admin; lib/core/api, models, security.
- Componentes: Flutter Android → HTTPS API → backend → SQL.
- Navegación: Catálogo ↔ Carrito ↔ Pedidos ↔ Cuenta/Administración.

## Pruebas y documentación
- Ejecutar `flutter test` y guardar captura del resultado.
- Ejecutar en emulador y teléfono; capturar cada pantalla y el flujo de compra.
- Registrar versiones con `flutter --version`, `dart --version`, `flutter doctor -v`.
- Iniciar Git: `git init`, `git add .`, `git commit -m "Prototipo Flutter TecnoTienda"`.
- Elaborar diagramas UML finales, descripción del entorno y reporte de pruebas.
