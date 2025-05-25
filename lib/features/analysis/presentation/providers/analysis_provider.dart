import 'package:flutter/foundation.dart';
import '../../domain/models/analysis_result.dart';
import '../../../../core/services/tflite_service.dart';

class AnalysisProvider extends ChangeNotifier {
  bool _isLoading = false;
  AnalysisResult? _result;
  String? _error;
  bool _isModelInitialized = false;

  final TFLiteService _tfliteService = TFLiteService();

  bool get isLoading => _isLoading;
  AnalysisResult? get result => _result;
  String? get error => _error;
  bool get isModelInitialized => _isModelInitialized;

  /// Inicializa el modelo de IA al crear el provider
  AnalysisProvider() {
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      _isModelInitialized = await _tfliteService.initializeModel();
      if (_isModelInitialized) {
        print('✅ Modelo de IA inicializado correctamente');
      } else {
        print('❌ Error al inicializar el modelo de IA');
      }
    } catch (e) {
      print('❌ Error al inicializar el modelo: $e');
      _isModelInitialized = false;
    }
  }

  Future<void> analyzeImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      if (!_isModelInitialized) {
        throw Exception(
            'El modelo de IA no está inicializado. Intenta reiniciar la app.');
      }

      // Usar TensorFlow Lite para análisis real
      final detections = await _tfliteService.detectObjects(imagePath);

      // Contar objetos por categoría
      final objectCounts = _tfliteService.countObjectsByCategory(detections);

      // Convertir a formato DetectedObject
      final detectedObjects = objectCounts.entries.map((entry) {
        // Calcular confianza promedio para esta categoría
        final categoryDetections =
            detections.where((d) => d.className == entry.key);
        final avgConfidence = categoryDetections.isEmpty
            ? 0.0
            : categoryDetections
                    .map((d) => d.confidence)
                    .reduce((a, b) => a + b) /
                categoryDetections.length;

        return DetectedObject(
          className: _translateClassName(entry.key),
          count: entry.value,
          confidence: avgConfidence,
        );
      }).toList();

      // Calcular total
      final totalCount =
          detectedObjects.fold<int>(0, (sum, obj) => sum + obj.count);

      _result = AnalysisResult(
        totalCount: totalCount,
        detectedObjects: detectedObjects,
        imagePath: imagePath,
        analysisDate: DateTime.now(),
      );

      print('✅ Análisis completado: $totalCount objetos detectados');
    } catch (e) {
      _error = 'Error al analizar la imagen: $e';
      print('❌ Error en análisis: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Traduce nombres de clases del inglés al español
  String _translateClassName(String englishName) {
    const translations = {
      'person': 'Personas',
      'bicycle': 'Bicicletas',
      'car': 'Coches',
      'motorcycle': 'Motocicletas',
      'airplane': 'Aviones',
      'bus': 'Autobuses',
      'train': 'Trenes',
      'truck': 'Camiones',
      'boat': 'Barcos',
      'traffic light': 'Semáforos',
      'fire hydrant': 'Bocas de incendio',
      'stop sign': 'Señales de stop',
      'parking meter': 'Parquímetros',
      'bench': 'Bancos',
      'bird': 'Pájaros',
      'cat': 'Gatos',
      'dog': 'Perros',
      'horse': 'Caballos',
      'sheep': 'Ovejas',
      'cow': 'Vacas',
      'elephant': 'Elefantes',
      'bear': 'Osos',
      'zebra': 'Cebras',
      'giraffe': 'Jirafas',
      'backpack': 'Mochilas',
      'umbrella': 'Paraguas',
      'handbag': 'Bolsos',
      'tie': 'Corbatas',
      'suitcase': 'Maletas',
      'frisbee': 'Frisbees',
      'skis': 'Esquís',
      'snowboard': 'Snowboards',
      'sports ball': 'Pelotas deportivas',
      'kite': 'Cometas',
      'baseball bat': 'Bates de béisbol',
      'baseball glove': 'Guantes de béisbol',
      'skateboard': 'Patinetas',
      'surfboard': 'Tablas de surf',
      'tennis racket': 'Raquetas de tenis',
      'bottle': 'Botellas',
      'wine glass': 'Copas de vino',
      'cup': 'Tazas',
      'fork': 'Tenedores',
      'knife': 'Cuchillos',
      'spoon': 'Cucharas',
      'bowl': 'Tazones',
      'banana': 'Plátanos',
      'apple': 'Manzanas',
      'sandwich': 'Sándwiches',
      'orange': 'Naranjas',
      'broccoli': 'Brócolis',
      'carrot': 'Zanahorias',
      'hot dog': 'Hot dogs',
      'pizza': 'Pizzas',
      'donut': 'Donuts',
      'cake': 'Pasteles',
      'chair': 'Sillas',
      'couch': 'Sofás',
      'potted plant': 'Plantas en maceta',
      'bed': 'Camas',
      'dining table': 'Mesas de comedor',
      'toilet': 'Inodoros',
      'tv': 'Televisores',
      'laptop': 'Laptops',
      'mouse': 'Ratones',
      'remote': 'Controles remotos',
      'keyboard': 'Teclados',
      'cell phone': 'Teléfonos móviles',
      'microwave': 'Microondas',
      'oven': 'Hornos',
      'toaster': 'Tostadoras',
      'sink': 'Fregaderos',
      'refrigerator': 'Refrigeradores',
      'book': 'Libros',
      'clock': 'Relojes',
      'vase': 'Jarrones',
      'scissors': 'Tijeras',
      'teddy bear': 'Osos de peluche',
      'hair drier': 'Secadores de pelo',
      'toothbrush': 'Cepillos de dientes',
    };

    return translations[englishName.toLowerCase()] ?? englishName;
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
