import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/svg_path.dart';

/// The eye outline of the Smart Surveillance mark on its 24 unit grid,
/// the same path as packages/brand/mark.svg.
const markOutline =
    'M2.5 12C5 7.5 8.4 5.5 12 5.5C15.6 5.5 19 7.5 21.5 12C19 16.5 15.6 18.5 12 18.5C8.4 18.5 5 16.5 2.5 12Z';

final _outline = parseSvgPath(markOutline);

/// The Smart Surveillance mark, optionally on a rounded tile.
class LogoMark extends StatelessWidget {
  /// Creates the mark at [size] logical pixels.
  const LogoMark({super.key, this.size = 56, this.framed = true, this.monochrome = false});

  /// The width and height of the mark, or of its tile when [framed].
  final double size;

  /// Whether to draw the mark on a rounded tile.
  final bool framed;

  /// Whether to draw the live dot in the mark's colour instead of red.
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mark = CustomPaint(
      size: Size.square(size * (framed ? 0.6 : 1)),
      painter: MarkPainter(color: p.text, dot: monochrome ? p.text : p.error),
    );
    return Semantics(
      label: 'Smart Surveillance',
      image: true,
      child: !framed
          ? mark
          : Container(
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

/// Paints the mark: the eye outline, the pupil and the live dot.
class MarkPainter extends CustomPainter {
  /// Creates a painter with the mark's [color] and the live [dot] colour.
  const MarkPainter({required this.color, required this.dot});

  /// The colour of the outline and the pupil.
  final Color color;

  /// The colour of the live dot.
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    canvas.drawPath(
      _outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(const Offset(12, 12), 3.25, Paint()..color = color);
    canvas.drawCircle(const Offset(19.5, 4.5), 1.75, Paint()..color = dot);
    canvas.restore();
  }

  @override
  bool shouldRepaint(MarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dot != dot;
}
