import 'dart:ui';

final _token = RegExp(r'[MmLlHhVvCcAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

/// Parses SVG path [data] into a [Path], supporting the M, L, H, V, C, A and Z commands.
Path parseSvgPath(String data) {
  final tokens = _token.allMatches(data).map((m) => m.group(0)!).toList();
  final path = Path();
  var index = 0;
  var command = 'M';
  var current = Offset.zero;
  var start = Offset.zero;

  bool isCommand(String value) => RegExp(r'^[A-Za-z]$').hasMatch(value);
  double next() => double.parse(tokens[index++]);
  bool flag() => next() != 0;

  while (index < tokens.length) {
    if (isCommand(tokens[index])) {
      command = tokens[index++];
    }
    final relative = command == command.toLowerCase();
    Offset point(double x, double y) => relative ? current + Offset(x, y) : Offset(x, y);
    switch (command.toUpperCase()) {
      case 'M':
        current = point(next(), next());
        start = current;
        path.moveTo(current.dx, current.dy);
        command = relative ? 'l' : 'L';
      case 'L':
        current = point(next(), next());
        path.lineTo(current.dx, current.dy);
      case 'H':
        final x = next();
        current = Offset(relative ? current.dx + x : x, current.dy);
        path.lineTo(current.dx, current.dy);
      case 'V':
        final y = next();
        current = Offset(current.dx, relative ? current.dy + y : y);
        path.lineTo(current.dx, current.dy);
      case 'C':
        final c1 = point(next(), next());
        final c2 = point(next(), next());
        final end = point(next(), next());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        current = end;
      case 'A':
        final rx = next();
        final ry = next();
        final rotation = next();
        final large = flag();
        final sweep = flag();
        final end = point(next(), next());
        path.arcToPoint(
          end,
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: large,
          clockwise: sweep,
        );
        current = end;
      case 'Z':
        path.close();
        current = start;
      default:
        index++;
    }
  }
  return path;
}
