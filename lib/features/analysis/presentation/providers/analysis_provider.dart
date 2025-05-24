import 'package:flutter/foundation.dart';
import '../../domain/models/analysis_result.dart';

class AnalysisProvider extends ChangeNotifier {
  bool _isLoading = false;
  AnalysisResult? _result;
  String? _error;

  bool get isLoading => _isLoading;
  AnalysisResult? get result => _result;
  String? get error => _error;

  Future<void> analyzeImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      // Simular análisis por ahora
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Implementar análisis real con TensorFlow Lite
      _result = AnalysisResult(
        totalCount: 12,
        detectedObjects: [
          DetectedObject(
            className: 'Troncos',
            count: 8,
            confidence: 0.95,
          ),
          DetectedObject(
            className: 'Ramas',
            count: 4,
            confidence: 0.87,
          ),
        ],
        imagePath: imagePath,
        analysisDate: DateTime.now(),
      );
    } catch (e) {
      _error = 'Error al analizar la imagen: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
