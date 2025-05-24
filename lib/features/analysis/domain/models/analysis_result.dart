class AnalysisResult {
  final int totalCount;
  final List<DetectedObject> detectedObjects;
  final String imagePath;
  final DateTime analysisDate;

  AnalysisResult({
    required this.totalCount,
    required this.detectedObjects,
    required this.imagePath,
    required this.analysisDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'detectedObjects': detectedObjects.map((e) => e.toJson()).toList(),
      'imagePath': imagePath,
      'analysisDate': analysisDate.toIso8601String(),
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      totalCount: json['totalCount'],
      detectedObjects: (json['detectedObjects'] as List)
          .map((e) => DetectedObject.fromJson(e))
          .toList(),
      imagePath: json['imagePath'],
      analysisDate: DateTime.parse(json['analysisDate']),
    );
  }
}

class DetectedObject {
  final String className;
  final int count;
  final double confidence;

  DetectedObject({
    required this.className,
    required this.count,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'count': count,
      'confidence': confidence,
    };
  }

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      className: json['className'],
      count: json['count'],
      confidence: json['confidence'],
    );
  }
}
