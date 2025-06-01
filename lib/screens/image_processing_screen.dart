import 'dart:io';
import 'package:flutter/material.dart';
import 'package:numera/widgets/segmentation_painter.dart';
import 'package:numera/services/object_segmentation_service.dart';
import 'package:numera/models/segmentation_result.dart';

class ImageProcessingScreen extends StatefulWidget {
  final File imageFile;

  const ImageProcessingScreen({super.key, required this.imageFile});

  @override
  State<ImageProcessingScreen> createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  late Image _image;
  bool _isLoading = true;
  bool _isProcessing = false;
  int _objectCount = 0;
  List<Offset> _brushPoints = [];
  final ObjectSegmentationService _segmentationService =
      ObjectSegmentationService();
  List<SegmentationResult> _segmentationResults = [];
  bool _isSegmentationMode = true;
  bool _isEraseMode = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    _image = Image.file(widget.imageFile);
    _image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        setState(() {
          _isLoading = false;
        });
      }),
    );
  }

  void _addBrushPoint(Offset point) {
    setState(() {
      _brushPoints = List.from(_brushPoints)..add(point);
    });
  }

  void _addStrokeBreak() {
    setState(() {
      _brushPoints = List.from(_brushPoints)..add(Offset.infinite);
    });
  }

  void _clearBrushPoints() {
    setState(() {
      _brushPoints = [];
    });
  }

  Future<void> _segmentObjects() async {
    if (_brushPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Marca con el pincel donde están los objetos')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Aquí utilizaríamos SAM para segmentar los objetos
      // Por ahora simularemos algunos resultados
      final results = await _segmentationService.segmentImage(
        widget.imageFile,
        _brushPoints,
      );

      setState(() {
        _segmentationResults = results;
        _objectCount = results.length;
        _isProcessing = false;
        _clearBrushPoints();
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar imagen: $e')),
      );
    }
  }

  void _resetSegmentation() {
    setState(() {
      _segmentationResults = [];
      _objectCount = 0;
      _clearBrushPoints();
    });
  }

  void _toggleDrawMode() {
    setState(() {
      _isEraseMode = !_isEraseMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesando imagen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEraseMode ? Icons.brush : Icons.auto_fix_high),
            onPressed: _toggleDrawMode,
            tooltip: _isEraseMode ? 'Modo dibujo' : 'Modo borrador',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen original
                      Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                      ),
                      // Resultados de segmentación
                      if (_segmentationResults.isNotEmpty)
                        CustomPaint(
                          painter: SegmentationPainter(
                            segmentationResults: _segmentationResults,
                          ),
                          size: Size.infinite,
                        ),
                      // Canvas de dibujo
                      if (_isSegmentationMode)
                        GestureDetector(
                          onPanUpdate: (details) {
                            _addBrushPoint(details.localPosition);
                          },
                          onPanEnd: (_) {
                            _addStrokeBreak();
                          },
                          child: CustomPaint(
                            painter: BrushPainter(
                              points: _brushPoints,
                              brushColor:
                                  _isEraseMode ? Colors.red : Colors.green,
                              brushWidth: 8.0,
                            ),
                            size: Size.infinite,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_objectCount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tag,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Objetos detectados: $_objectCount',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _segmentObjects,
                              icon: const Icon(Icons.auto_awesome),
                              label: Text(_isProcessing
                                  ? 'Procesando...'
                                  : 'Segmentar objetos'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _resetSegmentation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reiniciar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class BrushPainter extends CustomPainter {
  final List<Offset> points;
  final Color brushColor;
  final double brushWidth;

  BrushPainter({
    required this.points,
    required this.brushColor,
    required this.brushWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = brushColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushWidth;

    for (int i = 0; i < points.length - 1; i++) {
      // Solo dibujamos la línea si ninguno de los puntos es Offset.infinite
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

    // Dibujamos los círculos solo para los puntos que no son Offset.infinite
    for (final point in points) {
      if (point != Offset.infinite) {
        canvas.drawCircle(point, brushWidth / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BrushPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.brushColor != brushColor ||
      oldDelegate.brushWidth != brushWidth;
}
