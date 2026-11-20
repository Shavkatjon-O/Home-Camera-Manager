import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/widgets/synthetic_scene.dart';
class MediaView extends ConsumerWidget {
  const MediaView({super.key, required this.source, this.fit = BoxFit.cover, this.showStamp = true});

  final MediaSource? source;
  final BoxFit fit;
  final bool showStamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final placeholder = ColoredBox(color: p.frame, child: const SizedBox.expand());
    final media = source;
    return switch (media) {
      null => placeholder,
      SyntheticMedia() => SyntheticScene(media: media, showStamp: showStamp),
      MemoryMedia() => Image.memory(Uint8List.fromList(media.bytes), fit: fit, gaplessPlayback: true),
      NetworkMedia() => CachedNetworkImage(
        imageUrl: media.url,
        cacheKey: media.cacheKey,
        httpHeaders: ref.read(backendProvider).mediaHeaders(),
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 160),
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => ColoredBox(
          color: p.frame,
          child: Center(child: Icon(Icons.image_not_supported_outlined, color: p.text3, size: 22)),
        ),
      ),
    };
  }
}

class LensCrop extends StatelessWidget {
  const LensCrop({super.key, required this.lens, required this.lenses, required this.child});

  final int lens;
  final int lenses;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (lenses <= 1) return child;
    final y = lenses == 1 ? 0.0 : -1 + 2 * lens / (lenses - 1);
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          alignment: Alignment(0, y),
          minHeight: constraints.maxHeight * lenses,
          maxHeight: constraints.maxHeight * lenses,
          child: child,
        ),
      ),
    );
  }
}

class Frame extends StatelessWidget {
  const Frame({super.key, required this.aspect, required this.child, this.radius = 12, this.border = true});

  final double aspect;
  final Widget child;
  final double radius;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AspectRatio(
      aspectRatio: aspect,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: border ? Border.all(color: p.border) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ColoredBox(color: p.frame, child: child),
        ),
      ),
    );
  }
}

class BoxOverlay extends StatelessWidget {
  const BoxOverlay({super.key, required this.boxes, this.captions = const {}});

  final List<({Rect box, String label, String? caption})> boxes;
  final Map<String, String> captions;


  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(painter: _BoxPainter(boxes, context.palette), child: const SizedBox.expand()),
  );
}

class _BoxPainter extends CustomPainter {
  _BoxPainter(this.boxes, this.palette);

  final List<({Rect box, String label, String? caption})> boxes;
  final Palette palette;

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in boxes) {
      final color = palette.labelColor(item.label);
      final rect = Rect.fromLTRB(
        item.box.left.clamp(0, 1) * size.width,
        item.box.top.clamp(0, 1) * size.height,
        item.box.right.clamp(0, 1) * size.width,
        item.box.bottom.clamp(0, 1) * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final caption = item.caption;
      if (caption == null || caption.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(
          text: caption,
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color.computeLuminance() > 0.35 ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final above = rect.top - painter.height - 4 >= 0;
      final label = Rect.fromLTWH(
        rect.left,
        above ? rect.top - painter.height - 4 : rect.top,
        painter.width + 8,
        painter.height + 4,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(label, const Radius.circular(3)), Paint()..color = color);
      painter.paint(canvas, label.topLeft + const Offset(4, 2));
    }
  }

  @override
  bool shouldRepaint(_BoxPainter oldDelegate) => oldDelegate.boxes != boxes || oldDelegate.palette != palette;
}
