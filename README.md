# 📱 Numera

**Aplicación móvil de conteo y clasificación de objetos físicos mediante Inteligencia Artificial**

Numera es una aplicación Flutter que permite contar y clasificar objetos en imágenes de forma automática usando modelos de IA optimizados para funcionar completamente offline en dispositivos móviles.

## 🎯 Funcionalidades

- **📷 Captura de imágenes**: Toma fotos directamente con la cámara o carga imágenes desde la galería
- **🔍 Detección automática**: Identifica y cuenta objetos utilizando modelos de TensorFlow Lite
- **📊 Clasificación inteligente**: Agrupa objetos por categorías con niveles de confianza
- **📱 Completamente offline**: Todo el procesamiento se realiza en el dispositivo
- **📝 Historial de análisis**: Guarda y revisa análisis anteriores
- **🎨 Diseño moderno**: Interfaz minimalista con Material Design 3

## 🛠️ Tecnologías

- **Frontend**: Flutter (Dart)
- **IA/ML**: TensorFlow Lite para Flutter
- **Estado**: Provider
- **Base de datos**: SQLite
- **Cámara**: Camera & Image Picker plugins
- **UI**: Material Design 3 con Google Fonts

## 🎨 Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| Azul profundo | `#1C6E8C` | Color primario |
| Turquesa | `#74C0C4` | Color secundario |
| Gris claro | `#F4F7F9` | Fondo |
| Negro suave | `#1A1A1A` | Texto principal |
| Verde | `#4CAF50` | Éxito/Confirmación |
| Rojo | `#F44336` | Errores/Alertas |

## 📋 Casos de Uso

- **🌲 Silvicultura**: Conteo de troncos, ramas y árboles
- **🏗️ Construcción**: Inventario de materiales (tubos, vigas, ladrillos)
- **📦 Logística**: Conteo de cajas, paquetes y productos
- **🚜 Agricultura**: Análisis de cultivos y productos agrícolas
- **🔬 Investigación**: Conteo de muestras y especímenes

## 🚀 Instalación

### Requisitos previos

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (para desarrollo móvil)

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/oriolgds/Numera.git
   cd Numera
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── core/                       # Configuración central
│   └── theme/                 # Temas y colores
├── features/                  # Funcionalidades por módulos
│   ├── home/                  # Pantalla principal
│   ├── analysis/              # Análisis de imágenes
│   ├── history/               # Historial de análisis
│   └── settings/              # Configuración
└── main.dart                  # Punto de entrada
```

## 🔧 Configuración

### Permisos requeridos

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para tomar fotos de objetos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta app necesita acceso a la galería para cargar imágenes</string>
```

## 🤖 Integración de IA

La aplicación está preparada para integrar modelos de TensorFlow Lite:

1. **Coloca tu modelo** en `assets/models/`
2. **Actualiza** `pubspec.yaml` para incluir el modelo
3. **Implementa** la lógica de inferencia en `AnalysisProvider`

### Modelos compatibles
- COCO SSD (detección de objetos general)
- YOLOv5/YOLOv8 (optimizados para TFLite)
- Modelos personalizados entrenados

## 📱 Pantallas

1. **🏠 Home**: Captura de foto o carga de imagen
2. **🔍 Análisis**: Procesamiento y resultados en tiempo real
3. **📋 Historial**: Lista de análisis anteriores
4. **⚙️ Configuración**: Ajustes de la aplicación

## 🎯 Roadmap

- [ ] **v1.1**: Integración con modelo COCO SSD
- [ ] **v1.2**: Detección con bounding boxes visuales
- [ ] **v1.3**: Exportación de resultados (PDF/CSV)
- [ ] **v1.4**: Medición estimada de objetos
- [ ] **v2.0**: Entrenamiento de modelos personalizados

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE` para más información.

## 👨‍💻 Desarrollador

**Oriol García** - [@oriolgds](https://github.com/oriolgds)

## 🙏 Agradecimientos

- [Flutter Team](https://flutter.dev/) por el framework
- [TensorFlow](https://tensorflow.org/) por los modelos de IA
- [Material Design](https://material.io/) por las guías de diseño

---

⭐ **¡Dale una estrella si te gusta el proyecto!**
