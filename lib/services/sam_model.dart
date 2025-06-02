import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../models/segmentation_result.dart';

// Extensions to access color components from image pixels
extension ImagePixelExtension on img.Image {
  int getRed(int x, int y) {
    final pixel = getPixel(x, y);
    return pixel.r as int;
  }
  
  int getGreen(int x, int y) {
    final pixel = getPixel(x, y);
    return pixel.g as int;
  }
  
  int getBlue(int x, int y) {
    final pixel = getPixel(x, y);
    return pixel.b as int;
  }
}

// Define a global navigator key for accessing the app's navigation state
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class SAMModelService {
  bool _isInitialized = false;
  
  // Track model state
  bool get isModelLoaded => _isInitialized;
  
  Future<void> initialize() async {
    _isInitialized = true;
  }
  
  void dispose() {
    _isInitialized = false;
  }

  Future<List<SegmentationResult>> segmentImage(
    File imageFile, 
    List<Offset> promptPoints,
    Size imageSize,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Read the image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create a simple segmentation based on color similarity around the prompt points
      final results = <SegmentationResult>[];
      
      for (final point in promptPoints) {
        // Convert point to image coordinates
        final x = (point.dx * image.width / imageSize.width).round();
        final y = (point.dy * image.height / imageSize.height).round();
        
        // Skip if point is outside the image
        if (x < 0 || y < 0 || x >= image.width || y >= image.height) {
          continue;
        }
        
        // Get the color at the clicked point
        final r = image.getRed(x, y);
        final g = image.getGreen(x, y);
        final b = image.getBlue(x, y);
        
        // Create a simple threshold-based segmentation
        final mask = List.generate(image.height, (_) => List.filled(image.width, false));
        final visited = List.generate(image.height, (_) => List.filled(image.width, false));
        final queue = <List<int>>[[x, y]];
        const threshold = 30; // Color similarity threshold
        
        while (queue.isNotEmpty) {
          final current = queue.removeAt(0);
          final cx = current[0];
          final cy = current[1];
          
          // Skip if out of bounds or already visited
          if (cx < 0 || cy < 0 || cx >= image.width || cy >= image.height || visited[cy][cx]) {
            continue;
          }
          
          visited[cy][cx] = true;
          
          // Check color similarity
          final cr = image.getRed(cx, cy);
          final cg = image.getGreen(cx, cy);
          final cb = image.getBlue(cx, cy);
          
          final diff = (r - cr).abs() + (g - cg).abs() + (b - cb).abs();
          
          if (diff < threshold) {
            mask[cy][cx] = true;
            
            // Add neighbors to queue
            queue.add([cx + 1, cy]);
            queue.add([cx - 1, cy]);
            queue.add([cx, cy + 1]);
            queue.add([cx, cy - 1]);
          }
        }
        
        // Convert mask to path
        final path = _convertMaskToPath(mask, image.width, image.height);
        
        results.add(
          SegmentationResult(
            contour: path,
            center: point,
            confidence: 0.95,
          ),
        );
      }
      
      return results;
    } catch (e) {
      debugPrint('Error in segmentImage: $e');
      rethrow;
    }
  }
  


  /// Groups nearby points to avoid creating too many overlapping segments
  /// 
  /// Points within 30 pixels of each other will be merged into a single point
  /// at their average position.
  List<Offset> _groupPoints(List<Offset> points, Size imageSize) {
    if (points.isEmpty) return [];
    
    final grouped = <Offset>[];
    final double mergeDistance = 30.0; // Pixels within this distance will be merged
    
    for (final point in points) {
      if (point == Offset.infinite) continue;
      
      bool merged = false;
      for (var i = 0; i < grouped.length; i++) {
        final existing = grouped[i];
        final distance = (existing - point).distance;
        
        if (distance < mergeDistance) {
          // Merge points by averaging their positions
          grouped[i] = Offset(
            (existing.dx + point.dx) / 2,
            (existing.dy + point.dy) / 2,
          );
          merged = true;
          break;
        }
      }
      
      if (!merged) {
        grouped.add(point);
      }
    }
    
    return grouped;
  }
  
  /// Creates a circular boolean mask with the given dimensions and center point
  /// 
  /// The mask will be `true` for all pixels within `radius` of `center`,
  /// and `false` otherwise.
  List<List<bool>> _createCircularMask(
    int width,
    int height,
    Offset center, {
    required double radius,
  }) {
    final mask = List.generate(
      height,
      (_) => List.filled(width, false),
    );
    
    final radiusSquared = radius * radius;
    
    final startX = (center.dx - radius).clamp(0, width - 1).toInt();
    final endX = (center.dx + radius).clamp(0, width - 1).toInt();
    final startY = (center.dy - radius).clamp(0, height - 1).toInt();
    final endY = (center.dy + radius).clamp(0, height - 1).toInt();
    
    for (var y = startY; y <= endY; y++) {
      for (var x = startX; x <= endX; x++) {
        final dx = x - center.dx;
        final dy = y - center.dy;
        if (dx * dx + dy * dy <= radiusSquared) {
          mask[y][x] = true;
        }
      }
    }
    
    return mask;
  }



  /// Converts a boolean mask to a Flutter Path object for rendering
  /// 
  /// This creates a polygon that approximates the boundary between
  /// `true` and `false` values in the mask.
  Path _convertMaskToPath(List<List<bool>> mask, int width, int height) {
    // Convert the mask to a Flutter Path
    final path = Path();
    
    // This is a simplified version - in a real app, you'd want to use
    // a more sophisticated algorithm to convert the mask to a smooth path
    bool isDrawing = false;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (mask[y][x]) {
          if (!isDrawing) {
            path.moveTo(x.toDouble(), y.toDouble());
            isDrawing = true;
          } else {
            path.lineTo(x.toDouble(), y.toDouble());
          }
        } else {
          if (isDrawing) {
            isDrawing = false;
          }
        }
      }
    }
    
    return path;
  }
  
  void dispose() {
    // Clean up any resources here
    _isInitialized = false;
  }
}
