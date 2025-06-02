import 'dart:async';
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
  bool _isLoading = true;
  bool _isProcessing = false;
  int _objectCount = 0;
  List<Offset> _brushPoints = [];
  final ObjectSegmentationService _segmentationService = ObjectSegmentationService();
  List<SegmentationResult> _segmentationResults = [];
  bool _isSegmentationMode = true;
  bool _isEraseMode = false;
  Completer<ImageInfo>? _imageInfoCompleter;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _segmentationService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      await _segmentationService.initialize();
      await _loadImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing services: $e')),
        );
      }
    }
  }

  Future<ImageInfo?> _getImageInfo() async {
    if (_imageInfoCompleter != null && !_imageInfoCompleter!.isCompleted) {
      return _imageInfoCompleter!.future;
    }

    _imageInfoCompleter = Completer<ImageInfo>();
    final image = Image.file(widget.imageFile);
    
    final ImageStream stream = image.image.resolve(const ImageConfiguration());
    
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!_imageInfoCompleter!.isCompleted) {
        _imageInfoCompleter!.complete(info);
      }
    });
    
    stream.addListener(listener);
    
    // Add a timeout to prevent hanging
    return _imageInfoCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        stream.removeListener(listener);
        throw TimeoutException('Failed to load image info');
      },
    ).whenComplete(() => stream.removeListener(listener));
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger image info loading
      await _getImageInfo();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la imagen: $e')),
        );
      }
    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please mark the objects with the brush'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get the image size for proper point scaling
      final imageInfo = await _getImageInfo();
      if (imageInfo == null) {
        throw Exception('Could not get image information');
      }

      // Filter out any invalid points
      final validPoints = _brushPoints.where((p) => p != Offset.infinite).toList();
      
      if (validPoints.isEmpty) {
        throw Exception('No valid points provided for segmentation');
      }

      // Process the image first
      await _segmentationService.processImage(
        widget.imageFile,
        imageSize: Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        ),
      );

      // Add each point individually to see the segmentation update
      for (final point in validPoints) {
        await _segmentationService.addPromptPoint(point);
      }

      if (!mounted) return;
      
      // Get the final results from the service
      final results = _segmentationService.currentResults;
      
      setState(() {
        _segmentationResults = List.from(results);
        _objectCount = results.length;
        _isProcessing = false;
        _clearBrushPoints();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing image: $e')),
        );
      }
    }
  }

  Future<void> _resetSegmentation() async {
    try {
      // Get the current image size from the existing results if available
      Size? imageSize;
      if (_segmentationService.currentResults.isNotEmpty) {
        try {
          final bounds = _segmentationService.currentResults.first.contour.getBounds();
          imageSize = bounds.size;
        } catch (e) {
          debugPrint('Error getting bounds: $e');
        }
      }
      
      await _segmentationService.processImage(
        widget.imageFile,
        imageSize: imageSize,
      );
    } catch (e) {
      debugPrint('Error resetting segmentation: $e');
    }
    
    if (mounted) {
      setState(() {
        _segmentationResults = [];
        _objectCount = 0;
        _clearBrushPoints();
      });
    }
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
