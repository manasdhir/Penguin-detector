import 'package:flutter/material.dart';
import 'object_detection.dart';

import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<ObjectDetection> detections;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter(this.detections, this.imageWidth, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green // Change the color to green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0; // Change the thickness to 1.0

    for (final detection in detections) {
      final x = detection.x * imageWidth;
      final y = detection.y * imageHeight;
      final w = detection.width * imageWidth;
      final h = detection.height * imageHeight;

      // Draw the bounding box
      canvas.drawRect(Rect.fromLTRB(x, y, x + w, y + h), paint);

      // Draw the label above the bounding box
      /*final label = labels[detection.classId.toInt()];
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$label (${(detection.confidence * 100).toStringAsFixed(2)}%)',
          style:
              const TextStyle(color: Colors.green), // Change the color to green
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: imageWidth);*/

      // Calculate the position to draw the label above the bounding box
      //final labelLeft = x;
      //final labelTop = y - textPainter.height - 4; // Adjust for some padding

      //textPainter.paint(canvas, Offset(labelLeft, labelTop));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
