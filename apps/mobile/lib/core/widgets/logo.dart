import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/svg_path.dart';
const _markPaths = [
  'M16.75 12h3.632a1 1 0 0 1 .894 1.447l-2.034 4.069a1 1 0 0 1-1.708.134l-2.124-2.97',
  'M17.106 9.053a1 1 0 0 1 .447 1.341l-3.106 6.211a1 1 0 0 1-1.342.447L3.61 12.3a2.92 2.92 0 0 1-1.3-3.91L3.69 5.6a2.92 2.92 0 0 1 3.92-1.3z',
  'M2 19h3.76a2 2 0 0 0 1.8-1.1L9 15',
  'M2 21v-4',
  'M7 9h.01',
];

final _mark = [for (final data in _markPaths) parseSvgPath(data)];

class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 56, this.framed = true});

  final double size;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mark = CustomPaint(
      size: Size.square(size * (framed ? 0.56 : 1)),
      painter: _MarkPainter(p.text),
    );
    if (!framed) return Semantics(label: 'Smart Surveillance', child: mark);
    return Semantics(
      label: 'Smart Surveillance',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: p.surface2,
          borderRadius: BorderRadius.circular(size * 0.24),
          border: Border.all(color: p.borderInput),
        ),
        child: mark,
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final path in _mark) {
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}
