import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../models/segmentation_result.dart';
import 'sam_model.dart';

class ObjectSegmentationService {
  final SAMModelService _samService = SAMModelService();
  
  // Track the current image being processed
  File? _currentImageFile;
  Size? _currentImageSize;
  
  // Track the current segmentation results
  List<SegmentationResult> _currentResults = [];
  
  // Track the current prompt points
  final List<Offset> _currentPromptPoints = [];
  
  // Stream controller for segmentation results
  final StreamController<List<SegmentationResult>> _resultsController = 
      StreamController<List<SegmentationResult>>.broadcast();
  
  // Stream of segmentation results
  Stream<List<SegmentationResult>> get resultsStream => _resultsController.stream;
  
  // Get the current value of the stream or an empty list
  List<SegmentationResult> get currentResults => _currentResults;
  
  /// Adds a prompt point and updates the segmentation
  Future<void> addPromptPoint(Offset point) async {
    if (_currentImageFile == null || _currentImageSize == null) {
      throw Exception('No image loaded');
    }

    _currentPromptPoints.add(point);
    
    try {
      // Get segmentation results for the new points
      final results = await _samService.segmentImage(
        _currentImageFile!,
        _currentPromptPoints,
        _currentImageSize!,
      );
      
      // Update current results
      _currentResults = List.from(results);
      
      // Notify listeners
      _resultsController.add(_currentResults);
    } catch (e) {
      debugPrint('Error in addPromptPoint: $e');
      rethrow;
    }
  }
  
  // Track if the service is initialized
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _samService.initialize();
      _isInitialized = true;
    }
  }

  Future<List<SegmentationResult>> processImage(
    File imageFile, {
    Size? imageSize,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    _currentImageFile = imageFile;
    _currentImageSize = imageSize;
    
    // Get image dimensions if not provided
    if (_currentImageSize == null) {
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image != null) {
        _currentImageSize = Size(image.width.toDouble(), image.height.toDouble());
      } else {
        throw Exception('Failed to decode image');
      }
    }
    
    // Clear previous results and points
    _currentResults.clear();
    _currentPromptPoints.clear();
    
    // Notify listeners that results have been updated
    _resultsController.add(_currentResults);
    
    return _currentResults;
  }

  Future<List<SegmentationResult>> segmentImage(
    File imageFile,
    List<Offset> promptPoints, {
    Size? imageSize,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (promptPoints.isEmpty) {
      return [];
    }

    try {
      // Process the image
      await processImage(imageFile, imageSize: imageSize);
      
      // Ensure we have a valid image size
      if (_currentImageSize == null) {
        throw Exception('Image size not available');
      }

      // Use SAM model for segmentation
      final results = await _samService.segmentImage(
        _currentImageFile!,
        promptPoints,
        _currentImageSize!,
      );

      _currentResults = List.from(results);
      
      // Notify listeners that results have been updated
      _resultsController.add(_currentResults);
      
      return _currentResults;
    } catch (e) {
      debugPrint('Error in segmentImage: $e');
      rethrow;
    }
  }

  void dispose() {
    _samService.dispose();
    _isInitialized = false;
  }
}
