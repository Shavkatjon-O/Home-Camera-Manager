import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
/// A widget that draws a synthetic camera scene, used by the demo cameras instead of real video.
class SyntheticScene extends StatelessWidget {
  /// Creates a scene for [media], stamped with [clock] or the media's own time.
  const SyntheticScene({super.key, required this.media, this.clock, this.showStamp = true});

  /// The scene to draw.
  final SyntheticMedia media;
  /// The time shown in the camera stamp, overriding the time of [media].
  final DateTime? clock;
  /// Whether the date and time stamp is drawn in the corner.
  final bool showStamp;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: ScenePainter(media, clock ?? media.at, showStamp: showStamp),
    child: const SizedBox.expand(),
  );
}

/// A painter that draws a [SyntheticMedia] scene with its figures, grain and camera stamp.
class ScenePainter extends CustomPainter {
  /// Creates a painter for [media], stamping [clock] when [showStamp] is true.
  ScenePainter(this.media, this.clock, {this.showStamp = true});

  /// The scene to draw.
  final SyntheticMedia media;
  /// The time shown in the camera stamp, or null for no stamp.
  final DateTime? clock;
  /// Whether the date and time stamp is drawn.
  final bool showStamp;

  /// Returns [color] as seen by the camera: desaturated to grey at night, unchanged by day.
  Color tone(Color color) {
    if (!media.night) return color;
    final grey = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) * 0.82;
    return Color.from(alpha: color.a, red: grey * 0.96, green: grey, blue: grey * 1.02);
  }

  /// Returns a solid paint of [color], adjusted for night.
  Paint fill(Color color) => Paint()..color = tone(color);

  /// Returns a paint that blends [colors] from [begin] to [end] across [rect], adjusted for night.
  Paint gradient(Rect rect, List<Color> colors, {Alignment begin = Alignment.topCenter, Alignment end = Alignment.bottomCenter}) =>
      Paint()..shader = LinearGradient(begin: begin, end: end, colors: [for (final c in colors) tone(c)]).createShader(rect);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    canvas.clipRect(rect);
    final random = Random(media.seed);
    switch (media.scene) {
      case SceneKind.street:
        street(canvas, size, random);
      case SceneKind.yard:
        yard(canvas, size, random);
      case SceneKind.driveway:
        driveway(canvas, size, random);
      case SceneKind.hallway:
        hallway(canvas, size);
      case SceneKind.entrance:
        entrance(canvas, size);
      case SceneKind.checkout:
        checkout(canvas, size, random);
      case SceneKind.aisle:
        aisle(canvas, size, random);
      case SceneKind.stockroom:
        stockroom(canvas, size, random);
      case SceneKind.face:
        face(canvas, size, random);
    }
    if (media.scene != SceneKind.face) {
      for (final figure in media.figures) {
        drawFigure(canvas, size, figure);
      }
      grain(canvas, size, random);
      vignette(canvas, rect);
      if (showStamp && clock != null) stamp(canvas, size, clock!);
    }
    canvas.restore();
  }

  /// Draws a street scene with buildings along a road.
  void street(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.42;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizon), gradient(Rect.fromLTWH(0, 0, w, horizon), [const Color(0xFF5B6B7C), const Color(0xFF9AA5AE)]));
    for (var i = 0; i < 7; i++) {
      final bw = w * (0.08 + random.nextDouble() * 0.1);
      final bh = h * (0.12 + random.nextDouble() * 0.2);
      final x = i < 3 ? i * w * 0.11 : w * 0.6 + (i - 3) * w * 0.1;
      canvas.drawRect(Rect.fromLTWH(x, horizon - bh, bw, bh), fill(Color.lerp(const Color(0xFF3A4048), const Color(0xFF545B63), random.nextDouble())!));
      for (var r = 0; r < 3; r++) {
        canvas.drawRect(Rect.fromLTWH(x + bw * 0.2, horizon - bh + bh * (0.2 + r * 0.25), bw * 0.18, bh * 0.1), fill(const Color(0xFF7D8790)));
        canvas.drawRect(Rect.fromLTWH(x + bw * 0.6, horizon - bh + bh * (0.2 + r * 0.25), bw * 0.18, bh * 0.1), fill(const Color(0xFF6B747C)));
      }
    }
    final ground = Path()
      ..moveTo(0, horizon)
      ..lineTo(w, horizon)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ground, gradient(Rect.fromLTWH(0, horizon, w, h - horizon), [const Color(0xFF5E6266), const Color(0xFF3C3F42)]));
    final road = Path()
      ..moveTo(w * 0.42, horizon)
      ..lineTo(w * 0.58, horizon)
      ..lineTo(w * 1.05, h)
      ..lineTo(-w * 0.05, h)
      ..close();
    canvas.drawPath(road, gradient(Rect.fromLTWH(0, horizon, w, h - horizon), [const Color(0xFF45484C), const Color(0xFF2B2D30)]));
    final mark = Paint()
      ..color = tone(const Color(0xFFD9D4C2))
      ..strokeWidth = max(1.5, w * 0.006);
    for (var i = 0; i < 6; i++) {
      final t0 = i / 6;
      final t1 = t0 + 0.07;
      canvas.drawLine(Offset(w / 2, horizon + (h - horizon) * t0 * t0), Offset(w / 2, horizon + (h - horizon) * t1 * t1), mark);
    }
    canvas.drawRect(Rect.fromLTWH(0, horizon + h * 0.02, w * 0.18, h * 0.012), fill(const Color(0xFF7A7F84)));
  }

  /// Draws a yard scene.
  void yard(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final fence = h * 0.34;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, fence), gradient(Rect.fromLTWH(0, 0, w, fence), [const Color(0xFF6F8494), const Color(0xFFAFB9BF)]));
    canvas.drawRect(Rect.fromLTWH(0, fence * 0.55, w, fence * 0.45), fill(const Color(0xFF465A3E)));
    for (var x = 0.0; x < w; x += w * 0.045) {
      canvas.drawRect(Rect.fromLTWH(x, fence * 0.7, w * 0.03, fence * 0.36), fill(const Color(0xFF7B6A55)));
    }
    canvas.drawRect(Rect.fromLTWH(0, fence, w, h - fence), gradient(Rect.fromLTWH(0, fence, w, h - fence), [const Color(0xFF5D7048), const Color(0xFF3E4C30)]));
    final path = Path()
      ..moveTo(w * 0.46, fence)
      ..lineTo(w * 0.56, fence)
      ..lineTo(w * 0.8, h)
      ..lineTo(w * 0.34, h)
      ..close();
    canvas.drawPath(path, gradient(Rect.fromLTWH(0, fence, w, h - fence), [const Color(0xFF9A9180), const Color(0xFF6E675B)]));
    for (var i = 0; i < 3; i++) {
      final cx = w * (0.1 + i * 0.36) + random.nextDouble() * w * 0.05;
      canvas.drawCircle(Offset(cx, fence * 0.62), h * 0.1, fill(const Color(0xFF3C4E34)));
    }
  }

  /// Draws a driveway scene.
  void driveway(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final wall = h * 0.38;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, wall), gradient(Rect.fromLTWH(0, 0, w, wall), [const Color(0xFF8B8478), const Color(0xFF6E685F)]));
    canvas.drawRect(Rect.fromLTWH(w * 0.62, wall * 0.18, w * 0.26, wall * 0.82), fill(const Color(0xFF4E4A44)));
    canvas.drawRect(Rect.fromLTWH(w * 0.08, wall * 0.3, w * 0.18, wall * 0.3), fill(const Color(0xFF9FB1BD)));
    canvas.drawRect(Rect.fromLTWH(0, wall, w, h - wall), gradient(Rect.fromLTWH(0, wall, w, h - wall), [const Color(0xFF55585B), const Color(0xFF35373A)]));
    final line = Paint()
      ..color = tone(const Color(0xFFCFCBBF))
      ..strokeWidth = max(1.5, w * 0.005);
    for (var i = 0; i < 4; i++) {
      final x = w * (0.12 + i * 0.26);
      canvas.drawLine(Offset(x + (x - w / 2) * 0.1, wall + h * 0.04), Offset(x + (x - w / 2) * 0.6, h), line);
    }
  }

  /// Draws the walls and floor of a room whose far wall has the relative width [depth].
  void indoorBox(Canvas canvas, Size size, Color wall, Color floor, {double depth = 0.36}) {
    final w = size.width;
    final h = size.height;
    final back = Rect.fromLTWH(w * (0.5 - depth / 2), h * 0.24, w * depth, h * 0.36);
    canvas.drawRect(Offset.zero & size, gradient(Offset.zero & size, [wall, Color.lerp(wall, const Color(0xFF000000), 0.25)!]));
    final floorPath = Path()
      ..moveTo(back.left, back.bottom)
      ..lineTo(back.right, back.bottom)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(floorPath, gradient(Rect.fromLTWH(0, back.bottom, w, h - back.bottom), [floor, Color.lerp(floor, const Color(0xFF000000), 0.3)!]));
    final ceiling = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(back.right, back.top)
      ..lineTo(back.left, back.top)
      ..close();
    canvas.drawPath(ceiling, fill(Color.lerp(wall, const Color(0xFFFFFFFF), 0.12)!));
    canvas.drawRect(back, fill(Color.lerp(wall, const Color(0xFF000000), 0.12)!));
    final light = Paint()..color = tone(const Color(0xFFF4F1E6));
    for (var i = 0; i < 3; i++) {
      final t = 0.3 + i * 0.25;
      final cx = w / 2;
      final y = back.top * (1 - t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, y), width: w * (0.2 - i * 0.05), height: h * 0.018), const Radius.circular(2)),
        light,
      );
    }
  }

  /// Draws an indoor hallway scene.
  void hallway(Canvas canvas, Size size) {
    indoorBox(canvas, size, const Color(0xFF9C9488), const Color(0xFF6D5F50));
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.32, w * 0.1, h * 0.28), fill(const Color(0xFF5A4636)));
  }

  /// Draws a building entrance scene.
  void entrance(Canvas canvas, Size size) {
    indoorBox(canvas, size, const Color(0xFFA7A39B), const Color(0xFF5F5B55), depth: 0.5);
    final w = size.width;
    final h = size.height;
    final door = Rect.fromLTWH(w * 0.36, h * 0.26, w * 0.28, h * 0.34);
    canvas.drawRect(door, fill(const Color(0xFFBFD0DA)));
    final frame = Paint()
      ..color = tone(const Color(0xFF3F3F3F))
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2, w * 0.008);
    canvas.drawRect(door, frame);
    canvas.drawLine(door.topCenter, door.bottomCenter, frame);
    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.78, w * 0.4, h * 0.1), fill(const Color(0xFF3A3632)));
  }

  /// Draws a shop checkout scene.
  void checkout(Canvas canvas, Size size, Random random) {
    indoorBox(canvas, size, const Color(0xFFB4ADA2), const Color(0xFF8A8278), depth: 0.6);
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < 4; i++) {
      final shelf = Rect.fromLTWH(w * (0.22 + i * 0.15), h * 0.26, w * 0.12, h * 0.3);
      canvas.drawRect(shelf, fill(const Color(0xFF6E665C)));
      for (var r = 0; r < 4; r++) {
        canvas.drawRect(
          Rect.fromLTWH(shelf.left + shelf.width * 0.08, shelf.top + shelf.height * (0.08 + r * 0.23), shelf.width * 0.84, shelf.height * 0.14),
          fill(Color.lerp(const Color(0xFFB7553A), const Color(0xFF3E7EA6), random.nextDouble())!),
        );
      }
    }
    final counter = Path()
      ..moveTo(w * 0.04, h * 0.66)
      ..lineTo(w * 0.62, h * 0.62)
      ..lineTo(w * 0.7, h * 0.82)
      ..lineTo(0, h * 0.9)
      ..close();
    canvas.drawPath(counter, fill(const Color(0xFF3D3833)));
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.56, w * 0.08, h * 0.07), fill(const Color(0xFF222222)));
  }

  /// Draws a shop aisle scene.
  void aisle(Canvas canvas, Size size, Random random) {
    indoorBox(canvas, size, const Color(0xFFADA79C), const Color(0xFF8D877E), depth: 0.2);
    final w = size.width;
    final h = size.height;
    for (final left in [true, false]) {
      final path = Path();
      if (left) {
        path
          ..moveTo(0, h * 0.05)
          ..lineTo(w * 0.4, h * 0.26)
          ..lineTo(w * 0.4, h * 0.6)
          ..lineTo(0, h * 0.95)
          ..close();
      } else {
        path
          ..moveTo(w, h * 0.05)
          ..lineTo(w * 0.6, h * 0.26)
          ..lineTo(w * 0.6, h * 0.6)
          ..lineTo(w, h * 0.95)
          ..close();
      }
      canvas.drawPath(path, fill(const Color(0xFF6A6259)));
      for (var r = 0; r < 5; r++) {
        final t = r / 5;
        final x0 = left ? 0.0 : w;
        final x1 = left ? w * 0.4 : w * 0.6;
        final y0 = h * (0.08 + t * 0.85);
        final y1 = h * (0.27 + t * 0.32);
        final band = Paint()
          ..color = tone(Color.lerp(const Color(0xFFC1683F), const Color(0xFF4A8BB0), random.nextDouble())!)
          ..strokeWidth = h * 0.035;
        canvas.drawLine(Offset(x0, y0), Offset(x1, y1), band);
      }
    }
  }

  /// Draws a stockroom scene.
  void stockroom(Canvas canvas, Size size, Random random) {
    indoorBox(canvas, size, const Color(0xFF7F7A72), const Color(0xFF5B5852), depth: 0.55);
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < 9; i++) {
      final bw = w * (0.08 + random.nextDouble() * 0.06);
      final bh = h * (0.08 + random.nextDouble() * 0.06);
      final x = w * (0.04 + (i % 3) * 0.1) + (i ~/ 3) * w * 0.62;
      final y = h * 0.85 - bh * ((i ~/ 3) % 2 + 1) - (i % 3) * h * 0.02;
      canvas.drawRect(Rect.fromLTWH(x.clamp(0, w - bw), y, bw, bh), fill(Color.lerp(const Color(0xFF9C7B53), const Color(0xFFB8956A), random.nextDouble())!));
    }
  }

  /// Draws a face on a plain background.
  void face(Canvas canvas, Size size, Random random) {
    final w = size.width;
    final h = size.height;
    final hues = [const Color(0xFF6C7A86), const Color(0xFF7D6E62), const Color(0xFF5E7062), const Color(0xFF7A6A7E), const Color(0xFF6A6A6A)];
    canvas.drawRect(Offset.zero & size, gradient(Offset.zero & size, [hues[media.seed.abs() % hues.length], const Color(0xFF2E2E2E)]));
    final skins = [const Color(0xFFD7B59A), const Color(0xFFB98B6E), const Color(0xFFE2C4AD), const Color(0xFF9C6E52), const Color(0xFFC8A088)];
    final skin = skins[(media.seed.abs() ~/ 3) % skins.length];
    final hair = [const Color(0xFF2B2420), const Color(0xFF4A3528), const Color(0xFF151515), const Color(0xFF6B4A33)][media.seed.abs() % 4];
    canvas.drawOval(Rect.fromCenter(center: Offset(w / 2, h * 1.02), width: w * 0.95, height: h * 0.5), fill(const Color(0xFF3A4652)));
    canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h * 0.76), width: w * 0.22, height: h * 0.2), fill(skin));
    final head = Rect.fromCenter(center: Offset(w / 2, h * 0.46), width: w * 0.5, height: h * 0.6);
    canvas.drawOval(head, fill(skin));
    canvas.drawArc(head.inflate(w * 0.02), pi, pi, true, fill(hair));
    final eye = fill(const Color(0xFF2A211C));
    canvas.drawCircle(Offset(w * 0.4, h * 0.47), w * 0.025, eye);
    canvas.drawCircle(Offset(w * 0.6, h * 0.47), w * 0.025, eye);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w / 2, h * 0.62), width: w * 0.14, height: h * 0.018), const Radius.circular(4)),
      fill(const Color(0xFF8E5A4C)),
    );
  }

  /// Draws a simple person, vehicle, animal or generic shape for [figure], chosen by its label.
  void drawFigure(Canvas canvas, Size size, SceneFigure figure) {
    final box = Rect.fromLTRB(
      figure.box.left * size.width,
      figure.box.top * size.height,
      figure.box.right * size.width,
      figure.box.bottom * size.height,
    );
    if (figure.label == 'person') {
      final body = Rect.fromLTRB(box.left + box.width * 0.18, box.top + box.height * 0.2, box.right - box.width * 0.18, box.bottom);
      canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(box.width * 0.3)), fill(const Color(0xFF2F3A46)));
      canvas.drawRect(Rect.fromLTRB(body.left + body.width * 0.1, body.top + body.height * 0.55, body.right - body.width * 0.1, body.bottom), fill(const Color(0xFF23272B)));
      canvas.drawCircle(Offset(box.center.dx, box.top + box.height * 0.11), box.width * 0.24, fill(const Color(0xFFC9A387)));
    } else if (const {'car', 'truck', 'bus', 'vehicle'}.contains(figure.label)) {
      final body = RRect.fromRectAndRadius(Rect.fromLTRB(box.left, box.top + box.height * 0.3, box.right, box.bottom - box.height * 0.12), Radius.circular(box.height * 0.15));
      canvas.drawRRect(body, fill(const Color(0xFF8C2F2A)));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(box.left + box.width * 0.18, box.top, box.right - box.width * 0.18, box.top + box.height * 0.42), Radius.circular(box.height * 0.12)),
        fill(const Color(0xFF6D2420)),
      );
      canvas.drawRect(Rect.fromLTRB(box.left + box.width * 0.24, box.top + box.height * 0.06, box.right - box.width * 0.24, box.top + box.height * 0.34), fill(const Color(0xFF9FB4C2)));
      final wheel = fill(const Color(0xFF151515));
      canvas.drawCircle(Offset(box.left + box.width * 0.2, box.bottom - box.height * 0.12), box.height * 0.13, wheel);
      canvas.drawCircle(Offset(box.right - box.width * 0.2, box.bottom - box.height * 0.12), box.height * 0.13, wheel);
    } else if (const {'dog', 'cat', 'animal', 'bird'}.contains(figure.label)) {
      canvas.drawOval(Rect.fromLTRB(box.left, box.top + box.height * 0.35, box.right - box.width * 0.2, box.bottom - box.height * 0.1), fill(const Color(0xFF6B5240)));
      canvas.drawCircle(Offset(box.right - box.width * 0.2, box.top + box.height * 0.38), box.height * 0.22, fill(const Color(0xFF6B5240)));
    } else if (figure.label != 'covered') {
      canvas.drawRRect(RRect.fromRectAndRadius(box.deflate(box.width * 0.1), Radius.circular(box.width * 0.12)), fill(const Color(0xFF4F3B2C)));
    }
  }

  /// Draws film grain noise over the whole frame.
  void grain(Canvas canvas, Size size, Random random) {
    final dot = Paint()..color = const Color(0x16FFFFFF);
    final dark = Paint()..color = const Color(0x14000000);
    final count = (size.width * size.height / 900).clamp(80, 900).round();
    for (var i = 0; i < count; i++) {
      canvas.drawRect(Rect.fromLTWH(random.nextDouble() * size.width, random.nextDouble() * size.height, 1, 1), i.isEven ? dot : dark);
    }
  }

  /// Draws a darkening of the frame edges.
  void vignette(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [const Color(0x00000000), Color(media.night ? 0x66000000 : 0x40000000)],
          stops: const [0.62, 1],
        ).createShader(rect),
    );
  }

  /// Draws the date and time [at] in the top left corner of the frame.
  void stamp(Canvas canvas, Size size, DateTime at) {
    String two(int value) => value.toString().padLeft(2, '0');
    final text = '${at.year}-${two(at.month)}-${two(at.day)} ${two(at.hour)}:${two(at.minute)}:${two(at.second)}';
    final fontSize = (size.width * 0.03).clamp(7.0, 13.0);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: monoFamily,
          fontSize: fontSize,
          color: const Color(0xE6FFFFFF),
          shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(size.width * 0.025, size.height * 0.03));
  }

  @override
  bool shouldRepaint(ScenePainter oldDelegate) =>
      oldDelegate.media != media || oldDelegate.clock != clock || oldDelegate.showStamp != showStamp;
}
