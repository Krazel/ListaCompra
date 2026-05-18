# Lista Compra

App nativa para gestionar una lista de la compra compartible.

## Funciones

- Lista principal con productos, cantidades, categorias y borrado rapido.
- Catalogo de productos ya creados para anadirlos con cantidad.
- Plantillas personales como Compra semanal, Desayuno, Limpieza y Cena rapida.
- Pantalla de compartir con miembros, permisos y texto listo para enviar.
- Persistencia local en el dispositivo.

## IDs fijos

- iOS Bundle ID: `com.dmkr.listacompra`
- Android Package ID: `com.dmkr.listacompra`

## Estructura

- `native-ios/`: app iPhone nativa en SwiftUI.
- `android/`: app Android nativa en Java.
- `.github/workflows/build-ios-unsigned.yml`: build de IPA unsigned en GitHub Actions.
- `artifact/`: builds descargadas o copiadas localmente.
