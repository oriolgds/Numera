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
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');

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

      // Convertir a formato Float32 normalizado [0-1]
      final input = _imageToByteListFloat32(resizedImage);

      // Preparar outputs
      final outputLocations = Float32List(_numBoxes * 4);
      final outputClasses = Float32List(_numBoxes);
      final outputScores = Float32List(_numBoxes);
      final numDetections = Float32List(
          1); // Creamos las formas correctas para los tensores de salida
      final outputs = {
        0: [outputLocations], // [1, numBoxes, 4]
        1: [outputClasses], // [1, numBoxes]
        2: [outputScores], // [1, numBoxes]
        3: [numDetections], // [1]
      }; // Ejecutar inferencia
      // Necesitamos ajustar el formato de entrada para que coincida con lo que espera el modelo
      List<Object> inputs = [input];
      _interpreter!.runForMultipleInputs(inputs, outputs);

      // Procesar resultados
      return _processDetections(
        outputLocations,
        outputClasses,
        outputScores,
        numDetections[0].toInt(),
      );
    } catch (e) {
      print('Error en detección: $e');
      rethrow;
    }
  }

  /// Convierte imagen a formato Float32List normalizado
  Float32List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(_inputSize * _inputSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < _inputSize; i++) {
      for (int j = 0; j < _inputSize; j++) {
        final pixel = image.getPixel(j, i);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        buffer[pixelIndex++] = r / 255.0;
        buffer[pixelIndex++] = g / 255.0;
        buffer[pixelIndex++] = b / 255.0;
      }
    }

    // No podemos usar reshape directamente ya que devuelve List<dynamic>
    // En su lugar creamos un nuevo Float32List con la forma adecuada
    return convertedBytes;
  }

  /// Procesa las detecciones y filtra por confianza
  List<Detection> _processDetections(
    Float32List locations,
    Float32List classes,
    Float32List scores,
    int numDetections,
  ) {
    final detections = <Detection>[];
    const double confidenceThreshold = 0.5;

    for (int i = 0; i < numDetections && i < _numBoxes; i++) {
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
