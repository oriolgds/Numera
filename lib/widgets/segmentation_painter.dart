import 'package:flutter/material.dart';
import 'package:numera/models/segmentation_result.dart';

class SegmentationPainter extends CustomPainter {
  final List<SegmentationResult> segmentationResults;

  SegmentationPainter({required this.segmentationResults});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < segmentationResults.length; i++) {
      final result = segmentationResults[i];
      final paint = Paint()
        ..color = _getColorForIndex(i).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Dibujamos el contorno de cada objeto segmentado
      canvas.drawPath(result.contour, paint);

      // Dibujamos el borde con un color más oscuro
      final borderPaint = Paint()
        ..color = _getColorForIndex(i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawPath(result.contour, borderPaint);

      // Dibujamos el número del objeto
      final textSpan = TextSpan(
        text: '${i + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Calculamos el centro aproximado del contorno para colocar el número
      final center = result.center;
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    }
  }

  // Función para generar colores distintos para cada objeto
  Color _getColorForIndex(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) {
    return oldDelegate.segmentationResults != segmentationResults;
  }
}
