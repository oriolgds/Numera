class AnalysisResult {
  final int totalCount;
  final List<DetectedObject> detectedObjects;
  final String imagePath;
  final DateTime analysisDate;
  final List<ObjectBoundingBox>? boundingBoxes; // Nueva propiedad opcional

  AnalysisResult({
    required this.totalCount,
    required this.detectedObjects,
    required this.imagePath,
    required this.analysisDate,
    this.boundingBoxes,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'detectedObjects': detectedObjects.map((e) => e.toJson()).toList(),
      'imagePath': imagePath,
      'analysisDate': analysisDate.toIso8601String(),
      'boundingBoxes': boundingBoxes?.map((e) => e.toJson()).toList(),
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
      boundingBoxes: json['boundingBoxes'] != null
          ? (json['boundingBoxes'] as List)
              .map((e) => ObjectBoundingBox.fromJson(e))
              .toList()
          : null,
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

// Nueva clase para almacenar información de bounding boxes
class ObjectBoundingBox {
  final String className;
  final double x;
  final double y;
  final double width;
  final double height;
  final double confidence;

  ObjectBoundingBox({
    required this.className,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
    };
  }

  factory ObjectBoundingBox.fromJson(Map<String, dynamic> json) {
    return ObjectBoundingBox(
      className: json['className'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
      confidence: json['confidence'],
    );
  }
}
