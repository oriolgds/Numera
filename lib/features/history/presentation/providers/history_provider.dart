import 'package:flutter/foundation.dart';
import '../../domain/models/analysis_result.dart';

class HistoryProvider extends ChangeNotifier {
  final List<AnalysisResult> _history = [];

  List<AnalysisResult> get history => List.unmodifiable(_history);

  void addAnalysis(AnalysisResult result) {
    _history.insert(0, result);
    notifyListeners();
  }

  void removeAnalysis(AnalysisResult result) {
    _history.remove(result);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
