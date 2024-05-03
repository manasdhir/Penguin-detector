library object_detection;

import 'package:flutter/material.dart';

class ObjectDetection {
  // Your object detection-related code here
  final int x;
  final int y;
  final int width;
  final int height;
  final double confidence;
  final int classId;

  ObjectDetection({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
    required this.classId,
  });
}

List<ObjectDetection> decodeOutputTensor(
    List<List<List<int>>> outputTensor, List<String> labels) {
  // Your decoding code here
  final List<ObjectDetection> detections = [];

  for (final detection in outputTensor[0]) {
    final x = detection[0];
    final y = detection[1];
    final width = detection[2];
    final height = detection[3];
    final confidence = detection[4] / 255.0;
    final classId = detection[5];

    // You can use a threshold to filter out low-confidence detections
    if (confidence >= 0.1) {
      detections.add(
        ObjectDetection(
          x: x,
          y: y,
          width: width,
          height: height,
          confidence: confidence,
          classId: classId,
        ),
      );
    }
  }

  // Apply Non-Maximum Suppression (NMS) to remove duplicate and low-confidence boxes if needed

  return detections;
}
