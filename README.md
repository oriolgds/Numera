# 📱 Numera

**Aplicación móvil de conteo y clasificación de objetos físicos mediante Inteligencia Artificial**

Numera es una aplicación Flutter que permite contar y clasificar objetos en imágenes de forma automática usando modelos de IA optimizados para funcionar completamente offline en dispositivos móviles.

## 🎯 Funcionalidades

- **📷 Captura de imágenes**: Toma fotos directamente con la cámara o carga imágenes desde la galería
- **🔍 Detección automática**: Identifica y cuenta objetos utilizando modelos de TensorFlow Lite optimizados
- **📊 Clasificación inteligente**: Agrupa objetos por categorías con niveles de confianza
- **📱 Completamente offline**: Todo el procesamiento se realiza en el dispositivo
- **📝 Historial de análisis**: Guarda y revisa análisis anteriores
- **🎨 Diseño moderno**: Interfaz minimalista con Material Design 3
- **🎯 Detección precisa**: Soporte para modelos COCO SSD con 90+ categorías de objetos

## 🛠️ Tecnologías

- **Frontend**: Flutter (Dart)
- **IA/ML**: TensorFlow Lite para Flutter con soporte nativo para modelos SSD
- **Estado**: Provider
- **Base de datos**: SQLite
- **Cámara**: Camera (v0.10.5+5) & Image Picker plugins
- **UI**: Material Design 3 con Google Fonts
- **Procesamiento**: Optimización de imágenes con formato uint8 para máximo rendimiento

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

La aplicación utiliza TensorFlow Lite para **detectar y contar objetos individuales** en tiempo real:

1. **Coloca tu modelo** en `assets/models/detect.tflite`
2. **Incluye el labelmap** en `assets/models/labelmap.txt`
3. **Actualiza** `pubspec.yaml` para incluir los archivos del modelo
4. **El procesamiento** se realiza completamente offline usando modelos SSD

### Modelos compatibles y recomendados
- **COCO SSD MobileNet** (detección de objetos con bounding boxes)
- **YOLOv5/YOLOv8** convertidos a TensorFlow Lite
- **Modelos SSD personalizados** para casos específicos (conteo de inventario, etc.)

### Funcionamiento de la detección
- Cada objeto detectado cuenta como **1 unidad individual**
- Se muestran **bounding boxes** alrededor de cada objeto detectado
- **Filtrado por confianza** para evitar falsos positivos
- **Agrupación por categorías** con conteo automático

## 📱 Pantallas

1. **🏠 Home**: Captura de foto o carga de imagen para análisis
2. **🔍 Análisis**: Procesamiento con detección individual de objetos y bounding boxes
3. **📋 Historial**: Lista de análisis anteriores con conteos detallados
4. **⚙️ Configuración**: Ajustes de confianza y categorías de detección
