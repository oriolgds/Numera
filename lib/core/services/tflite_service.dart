import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  static const String _modelPath = 'assets/models/detect.tflite';
  static const String _labelsPath = 'assets/models/labelmap.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  // Configuración del modelo COCO SSD MobileNet
  static const int _inputSize = 300;
  static const int _numClasses = 90;
  static const int _numBoxes = 10;

  bool get isModelLoaded => _interpreter != null && _labels != null;

  /// Inicializa el modelo TensorFlow Lite
  Future<bool> initializeModel() async {
    try {
      // Cargar el modelo
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Cargar las etiquetas
      await _loadLabels();

      print('Modelo TensorFlow Lite cargado exitosamente');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output tensors: ${_interpreter!.getOutputTensors().length}');
      for (int i = 0; i < _interpreter!.getOutputTensors().length; i++) {
        print('Output $i shape: ${_interpreter!.getOutputTensor(i).shape}');
      }

      return true;
    } catch (e) {
      print('Error cargando el modelo: $e');
      return false;
    }
  }

  /// Carga las etiquetas del archivo labelmap.txt
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels =
          labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      print('Etiquetas cargadas: ${_labels!.length}');
    } catch (e) {
      print('Error cargando etiquetas: $e');
      _labels = [];
    }
  }

  /// Procesa una imagen y detecta objetos
  Future<List<Detection>> detectObjects(String imagePath) async {
    if (!isModelLoaded) {
      throw Exception('Modelo no inicializado');
    }

    try {
      // Cargar y procesar la imagen
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar la imagen
      final resizedImage =
          img.copyResize(image, width: _inputSize, height: _inputSize);

      // Convertir a formato Uint8 con dimensión de batch
      final input = _imageToByteListUint8(resizedImage);

      // Preparar outputs basados en el modelo SSD MobileNet
      final outputLocations = List.generate(1, (index) => List.filled(_numBoxes * 4, 0.0));
      final outputClasses = List.generate(1, (index) => List.filled(_numBoxes, 0.0));
      final outputScores = List.generate(1, (index) => List.filled(_numBoxes, 0.0));
      final numDetections = List.filled(1, 0.0);

      final outputs = {
        0: outputLocations,
        1: outputClasses,  
        2: outputScores,
        3: numDetections,
      };

      // Ejecutar inferencia
      _interpreter!.runForMultipleInputs([input], outputs);

      // Procesar resultados
      return _processDetections(
        outputLocations[0].cast<double>(),
        outputClasses[0].cast<double>(),
        outputScores[0].cast<double>(),
        numDetections[0].toInt(),
      );
    } catch (e) {
      print('Error en detección: $e');
      rethrow;
    }
  }

  /// Convierte imagen a formato Uint8List con dimensión de batch [1, 300, 300, 3]
  Uint8List _imageToByteListUint8(img.Image image) {
    // Crear buffer para tensor 4D: [batch, height, width, channels]
    final bytes = Uint8List(1 * _inputSize * _inputSize * 3);
    int pixelIndex = 0;

    for (int h = 0; h < _inputSize; h++) {
      for (int w = 0; w < _inputSize; w++) {
        final pixel = image.getPixel(w, h);
        bytes[pixelIndex++] = pixel.r.toInt(); // Red
        bytes[pixelIndex++] = pixel.g.toInt(); // Green  
        bytes[pixelIndex++] = pixel.b.toInt(); // Blue
      }
    }

    return bytes;
  }

  /// Procesa las detecciones y filtra por confianza
  List<Detection> _processDetections(
    List<double> locations,
    List<double> classes,
    List<double> scores,
    int numDetections,
  ) {
    final detections = <Detection>[];
    const double confidenceThreshold = 0.5;

    final actualDetections = numDetections.clamp(0, _numBoxes);
    print('Procesando $actualDetections detecciones');

    for (int i = 0; i < actualDetections; i++) {
      final score = scores[i];
      if (score < confidenceThreshold) continue;

      final classId = classes[i].toInt();
      final className = _getClassName(classId);

      final detection = Detection(
        classId: classId,
        className: className,
        confidence: score,
        boundingBox: BoundingBox(
          top: locations[i * 4],
          left: locations[i * 4 + 1],
          bottom: locations[i * 4 + 2],
          right: locations[i * 4 + 3],
        ),
      );

      detections.add(detection);
      print('Detectado: $className con confianza ${(score * 100).toStringAsFixed(1)}%');
    }

    return detections;
  }

  /// Obtiene el nombre de la clase por ID
  String _getClassName(int classId) {
    if (_labels == null || classId >= _labels!.length || classId < 0) {
      return 'Unknown';
    }
    return _labels![classId];
  }

  /// Cuenta objetos por categoría
  Map<String, int> countObjectsByCategory(List<Detection> detections) {
    final counts = <String, int>{};

    for (final detection in detections) {
      final className = detection.className;
      counts[className] = (counts[className] ?? 0) + 1;
    }

    return counts;
  }

  /// Libera recursos
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}

/// Clase para representar una detección
class Detection {
  final int classId;
  final String className;
  final double confidence;
  final BoundingBox boundingBox;

  Detection({
    required this.classId,
    required this.className,
    required this.confidence,
    required this.boundingBox,
  });

  @override
  String toString() {
    return 'Detection(className: $className, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
  }
}

/// Clase para representar una caja delimitadora
class BoundingBox {
  final double top;
  final double left;
  final double bottom;
  final double right;

  BoundingBox({
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
  });

  double get width => right - left;
  double get height => bottom - top;
}
