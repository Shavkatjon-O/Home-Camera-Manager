import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';

/// Moves a camera by pan, tilt and zoom speeds.
typedef PtzMove = Future<void> Function(double pan, double tilt, double zoom);

/// A directional pad that pans and tilts a camera while it is held.
class PtzPad extends StatefulWidget {
  /// Creates a pad of [size] that calls [onMove] and [onStop], and [onHome] when given.
  const PtzPad({
    super.key,
    required this.onMove,
    required this.onStop,
    this.onHome,
    required this.speed,
    this.size = 196,
  });

  /// Called with the speeds to apply while a direction is held.
  final PtzMove onMove;

  /// Called when the direction is released.
  final Future<void> Function() onStop;

  /// Called when the centre button asks for the home position, or null to hide it.
  final VoidCallback? onHome;

  /// The speed applied to a movement.
  final double speed;

  /// The width and height of the pad.
  final double size;

  @override
  State<PtzPad> createState() => _PtzPadState();
}

class _PtzPadState extends State<PtzPad> {
  Offset? active;

  Future<void> press(Offset direction) async {
    setState(() => active = direction);
    unawaited(HapticFeedback.selectionClick());
    await widget.onMove(direction.dx * widget.speed, -direction.dy * widget.speed, 0);
  }

  Future<void> release() async {
    if (active == null) return;
    setState(() => active = null);
    await widget.onStop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final size = widget.size;
    Widget arrow(Offset direction, IconData icon, String label, Alignment alignment) {
      final selected = active == direction;
      return Align(
        alignment: alignment,
        child: Semantics(
          button: true,
          label: label,
          child: Listener(
            onPointerDown: (_) => press(direction),
            onPointerUp: (_) => release(),
            onPointerCancel: (_) => release(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: selected ? p.surface3 : const Color(0x00000000),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: selected ? p.text : p.text2),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: p.borderInput),
        ),
        child: Stack(
          children: [
            arrow(
              const Offset(0, -1),
              Icons.keyboard_arrow_up_rounded,
              l10n.ptzUp,
              Alignment.topCenter,
            ),
            arrow(
              const Offset(0, 1),
              Icons.keyboard_arrow_down_rounded,
              l10n.ptzDown,
              Alignment.bottomCenter,
            ),
            arrow(
              const Offset(-1, 0),
              Icons.keyboard_arrow_left_rounded,
              l10n.ptzLeft,
              Alignment.centerLeft,
            ),
            arrow(
              const Offset(1, 0),
              Icons.keyboard_arrow_right_rounded,
              l10n.ptzRight,
              Alignment.centerRight,
            ),
            Center(
              child: Material(
                color: p.surface,
                shape: CircleBorder(side: BorderSide(color: p.borderInput)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onHome,
                  child: SizedBox(
                    width: size * 0.3,
                    height: size * 0.3,
                    child: Tooltip(
                      message: l10n.cameraHome,
                      child: Icon(
                        Icons.home_outlined,
                        color: widget.onHome == null ? p.text3 : p.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A pair of buttons that zoom a camera in and out while held.
class ZoomButtons extends StatelessWidget {
  /// Creates buttons that call [onMove] and [onStop] at [speed].
  const ZoomButtons({super.key, required this.onMove, required this.onStop, required this.speed});

  /// Called with the speeds to apply while a button is held.
  final PtzMove onMove;

  /// Called when the button is released.
  final Future<void> Function() onStop;

  /// The speed applied to a zoom movement.
  final double speed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    Widget button(IconData icon, String label, double zoom) => Semantics(
      button: true,
      label: label,
      child: Listener(
        onPointerDown: (_) => onMove(0, 0, zoom * speed),
        onPointerUp: (_) => onStop(),
        onPointerCancel: (_) => onStop(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: p.surface2,
            shape: BoxShape.circle,
            border: Border.all(color: p.borderInput),
          ),
          child: Icon(icon, color: p.text2),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.add_rounded, l10n.cameraZoomIn, 1),
        const SizedBox(height: 12),
        button(Icons.remove_rounded, l10n.cameraZoomOut, -1),
      ],
    );
  }
}
