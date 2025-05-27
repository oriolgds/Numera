import 'package:flutter/material.dart';
import '../../domain/models/analysis_result.dart';

class DetectionPainter extends CustomPainter {
  final List<ObjectBoundingBox> boxes;
  final Size originalImageSize;

  DetectionPainter({
    required this.boxes,
    required this.originalImageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var box in boxes) {
      // Convertir coordenadas normalizadas a píxeles en la pantalla
      final rect = Rect.fromLTRB(
        box.x * size.width,
        box.y * size.height,
        (box.x + box.width) * size.width,
        (box.y + box.height) * size.height,
      );

      // Dibujar el rectángulo
      canvas.drawRect(rect, paint);

      // Preparar el texto
      textPainter.text = TextSpan(
        text: '${box.className} ${(box.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
          fontSize: 12,
        ),
      );

      // Configurar el texto
      textPainter.layout();

      // Dibujar fondo del texto
      final textBackgroundRect = Rect.fromLTWH(
        rect.left,
        rect.top - textPainter.height,
        textPainter.width + 4,
        textPainter.height,
      );
      canvas.drawRect(
        textBackgroundRect,
        Paint()..color = Colors.red,
      );

      // Dibujar el texto
      textPainter.paint(
        canvas,
        Offset(rect.left + 2, rect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
