# Build Android

Desde `C:\Users\dmkra\Documents\Codex Apps`:

```powershell
.\android-env.bat
cd ListaCompra\android
.\gradlew.bat assembleDebug
```

El APK debug queda en:

```text
android/app/build/outputs/apk/debug/app-debug.apk
```

Para dejarlo como artifact:

```powershell
Copy-Item android\app\build\outputs\apk\debug\app-debug.apk artifact\ListaCompra-Android-v1.0-local.apk
```
