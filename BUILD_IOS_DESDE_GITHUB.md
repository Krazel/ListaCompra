# Build iOS desde GitHub

La app iPhone se compila con GitHub Actions porque requiere macOS y Xcode.

Workflow:

```text
.github/workflows/build-ios-unsigned.yml
```

Cuando el repo este publicado, se puede lanzar manualmente desde GitHub Actions o hacer push a `main`.

Para vigilar y descargar la ultima IPA:

```powershell
.\watch-ipa.bat
```
