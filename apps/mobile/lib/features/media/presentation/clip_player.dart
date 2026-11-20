import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/media/media_source.dart';
import 'package:smart_surveillance/core/widgets/synthetic_scene.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
import 'package:video_player/video_player.dart';
class ClipPlayer extends ConsumerStatefulWidget {
  const ClipPlayer({super.key, required this.clip, required this.aspect});

  final ClipSource clip;
  final double aspect;

  @override
  ConsumerState<ClipPlayer> createState() => _ClipPlayerState();
}

class _ClipPlayerState extends ConsumerState<ClipPlayer> with SingleTickerProviderStateMixin {
  VideoPlayerController? video;
  AnimationController? synthetic;
  Object? error;

  @override
  void initState() {
    super.initState();
    final clip = widget.clip;
    switch (clip) {
      case NetworkClip():
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(clip.url),
          httpHeaders: ref.read(backendProvider).mediaHeaders(),
        );
        video = controller;
        controller.addListener(() {
          if (mounted) setState(() {});
        });
        unawaited(
          controller.initialize().then((_) => controller.play()).catchError((Object failure) {
            if (mounted) setState(() => error = failure);
          }),
        );
      case SyntheticClip():
        synthetic = AnimationController(vsync: this, duration: clip.length)..forward();
        synthetic!.addListener(() {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    unawaited(video?.dispose());
    synthetic?.dispose();
    super.dispose();
  }

  bool get playing => video?.value.isPlaying ?? (synthetic?.isAnimating ?? false);

  double get progress {
    final v = video;
    if (v != null) {
      final total = v.value.duration.inMilliseconds;
      return total == 0 ? 0 : v.value.position.inMilliseconds / total;
    }
    return synthetic?.value ?? 0;
  }

  Duration get length => video?.value.duration ?? (widget.clip is SyntheticClip ? (widget.clip as SyntheticClip).length : Duration.zero);

  void toggle() {
    final v = video;
    if (v != null) {
      if (v.value.isPlaying) {
        unawaited(v.pause());
      } else {
        if (progress >= 0.999) unawaited(v.seekTo(Duration.zero));
        unawaited(v.play());
      }
      return;
    }
    final s = synthetic!;
    if (s.isAnimating) {
      s.stop();
    } else {
      if (s.value >= 1) s.value = 0;
      unawaited(s.forward());
    }
    setState(() {});
  }

  void seek(double value) {
    final v = video;
    if (v != null) {
      unawaited(v.seekTo(v.value.duration * value));
    } else {
      synthetic!.value = value;
    }
  }

  String stamp(Duration value) =>
      '${value.inMinutes.toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget picture() {
    final clip = widget.clip;
    if (clip is SyntheticClip) {
      final t = synthetic!.value;
      final moved = [
        for (final box in clip.boxes)
          SceneFigure(box.label, box.box.shift(Offset((t - 0.5) * 0.25, (t - 0.5) * 0.04))),
      ];
      final at = clip.media.at?.subtract(const Duration(seconds: 5)).add(clip.length * t);
      return SyntheticScene(media: clip.media.withFigures(moved, at: at));
    }
    final v = video!;
    if (error != null) {
      return Center(child: Icon(Icons.error_outline_rounded, color: context.palette.text3));
    }
    if (!v.value.isInitialized) {
      return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
    }
    return FittedBox(
      child: SizedBox(width: v.value.size.width, height: v.value.size.height, child: VideoPlayer(v)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: widget.aspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.medium),
            child: GestureDetector(
              onTap: toggle,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: p.frame, child: picture()),
                  AnimatedOpacity(
                    opacity: playing ? 0 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
                        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFFFFFFFF), size: 32),
                      ),
                    ),
                  ),
                  if (widget.clip is SyntheticClip)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0x99000000), borderRadius: BorderRadius.circular(4)),
                        child: Text(l10n.eventDemoClip, style: const TextStyle(fontSize: 10.5, color: Color(0xFFFFFFFF))),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              tooltip: l10n.eventClip,
              onPressed: toggle,
              icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
            ),
            Text(stamp(length * progress), style: dataStyle(context, size: 12, color: p.text2)),
            Expanded(child: Slider(value: progress.clamp(0, 1), onChanged: seek)),
            Text(stamp(length), style: dataStyle(context, size: 12, color: p.text3)),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
