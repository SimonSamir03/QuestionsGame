// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);
  final center = size / 2;

  // ── Background: rounded gradient feel ──
  // Deep navy base
  final bgColor = img.ColorRgba8(26, 26, 46, 255); // #1a1a2e
  img.fill(image, color: bgColor);

  // Draw radial gradient overlay (lighter center)
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final dx = x - center;
      final dy = y - center;
      final dist = sqrt(dx * dx + dy * dy) / (size * 0.7);
      final t = (1.0 - dist).clamp(0.0, 1.0);
      // Blend toward a slightly lighter purple at center
      final r = (26 + (30 * t)).round().clamp(0, 255);
      final g = (26 + (20 * t)).round().clamp(0, 255);
      final b = (46 + (60 * t)).round().clamp(0, 255);
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // ── Draw a brain-shaped icon using circles ──
  // Brain left half
  _fillCircle(image, (center - 120).round(), (center - 80).round(), 180,
      img.ColorRgba8(138, 79, 255, 255)); // purple
  _fillCircle(image, (center - 160).round(), (center + 60).round(), 150,
      img.ColorRgba8(138, 79, 255, 255));
  _fillCircle(image, (center - 80).round(), (center + 160).round(), 130,
      img.ColorRgba8(138, 79, 255, 255));

  // Brain right half
  _fillCircle(image, (center + 120).round(), (center - 80).round(), 180,
      img.ColorRgba8(79, 172, 255, 255)); // blue
  _fillCircle(image, (center + 160).round(), (center + 60).round(), 150,
      img.ColorRgba8(79, 172, 255, 255));
  _fillCircle(image, (center + 80).round(), (center + 160).round(), 130,
      img.ColorRgba8(79, 172, 255, 255));

  // Center divider line (dark gap between halves)
  for (int y = (center - 260).round(); y < (center + 280).round(); y++) {
    for (int x = (center - 12).round(); x < (center + 12).round(); x++) {
      if (x >= 0 && x < size && y >= 0 && y < size) {
        image.setPixelRgba(x, y, 26, 26, 46, 255);
      }
    }
  }

  // ── Lightning bolt (play/energy symbol) ──
  _fillPolygon(image, [
    Point(center.round() + 10, center.round() - 200),
    Point(center.round() - 60, center.round() + 20),
    Point(center.round() + 5, center.round() + 20),
    Point(center.round() - 10, center.round() + 200),
    Point(center.round() + 60, center.round() - 20),
    Point(center.round() - 5, center.round() - 20),
  ], img.ColorRgba8(255, 214, 0, 255)); // golden yellow

  // ── Outer glow ring ──
  _drawCircleOutline(image, center.round(), center.round(), 440, 8,
      img.ColorRgba8(138, 79, 255, 100));
  _drawCircleOutline(image, center.round(), center.round(), 460, 4,
      img.ColorRgba8(79, 172, 255, 60));

  // Save
  final outputPath = 'assets/icon/app_icon.png';
  File(outputPath).writeAsBytesSync(img.encodePng(image));
  if (kDebugMode) {
    print('Icon saved to $outputPath (${size}x$size)');
  }
}

void _fillCircle(img.Image image, int cx, int cy, int radius, img.Color color) {
  final r = color.r.toInt();
  final g = color.g.toInt();
  final b = color.b.toInt();
  final a = color.a.toInt();
  for (int y = cy - radius; y <= cy + radius; y++) {
    for (int x = cx - radius; x <= cx + radius; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy <= radius * radius) {
          // Edge softening
          final dist = sqrt((dx * dx + dy * dy).toDouble());
          final edge = ((radius - dist) / 3.0).clamp(0.0, 1.0);
          final existing = image.getPixel(x, y);
          final nr = (existing.r * (1 - edge) + r * edge).round().clamp(0, 255);
          final ng = (existing.g * (1 - edge) + g * edge).round().clamp(0, 255);
          final nb = (existing.b * (1 - edge) + b * edge).round().clamp(0, 255);
          image.setPixelRgba(x, y, nr, ng, nb, a);
        }
      }
    }
  }
}

void _drawCircleOutline(
    img.Image image, int cx, int cy, int radius, int thickness, img.Color color) {
  final r = color.r.toInt();
  final g = color.g.toInt();
  final b = color.b.toInt();
  final a = color.a.toInt() / 255.0;
  for (int y = cy - radius - thickness; y <= cy + radius + thickness; y++) {
    for (int x = cx - radius - thickness; x <= cx + radius + thickness; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        final dx = x - cx;
        final dy = y - cy;
        final dist = sqrt((dx * dx + dy * dy).toDouble());
        if ((dist - radius).abs() <= thickness / 2) {
          final existing = image.getPixel(x, y);
          final nr = (existing.r * (1 - a) + r * a).round().clamp(0, 255);
          final ng = (existing.g * (1 - a) + g * a).round().clamp(0, 255);
          final nb = (existing.b * (1 - a) + b * a).round().clamp(0, 255);
          image.setPixelRgba(x, y, nr, ng, nb, 255);
        }
      }
    }
  }
}

void _fillPolygon(img.Image image, List<Point> points, img.Color color) {
  final r = color.r.toInt();
  final g = color.g.toInt();
  final b = color.b.toInt();

  int minY = points.map((p) => p.y).reduce(min);
  int maxY = points.map((p) => p.y).reduce(max);
  int minX = points.map((p) => p.x).reduce(min);
  int maxX = points.map((p) => p.x).reduce(max);

  for (int y = minY; y <= maxY; y++) {
    for (int x = minX; x <= maxX; x++) {
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        if (_pointInPolygon(x, y, points)) {
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
}

bool _pointInPolygon(int px, int py, List<Point> polygon) {
  bool inside = false;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; j = i++) {
    final xi = polygon[i].x, yi = polygon[i].y;
    final xj = polygon[j].x, yj = polygon[j].y;
    if (((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi)) {
      inside = !inside;
    }
  }
  return inside;
}

class Point {
  final int x, y;
  Point(this.x, this.y);
}
