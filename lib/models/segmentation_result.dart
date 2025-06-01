import 'dart:ui';

class SegmentationResult {
  final Path contour;
  final Offset center;
  final double confidence;
  final String? label;

  SegmentationResult({
    required this.contour,
    required this.center,
    required this.confidence,
    this.label,
  });
}
