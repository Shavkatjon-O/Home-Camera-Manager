import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/synthetic_scene.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/media/domain/media_repository.dart';
/// The connection state of a live picture.
enum LiveState {
  /// The picture is being set up.
  connecting,
  /// The picture is playing.
  playing,
  /// The picture could not be started.
  failed,
  /// The camera is offline.
  offline,
}

/// A live picture of a camera that reports its connection state.
class LiveVideo extends ConsumerStatefulWidget {
  /// Creates a live picture of [camera] at [quality], with sound when [audio] is true.
  const LiveVideo({
    super.key,
    required this.camera,
    this.lens,
    this.quality = StreamQuality.sub,
    this.audio = false,
    this.overlay,
    this.onState,
  });

  /// The camera shown.
  final Camera camera;
  /// The lens shown, or null for all lenses.
  final int? lens;
  /// The stream that is played.
  final StreamQuality quality;
  /// Whether sound is played.
  final bool audio;
  /// A widget drawn over the picture.
  final Widget? overlay;
  /// Called when the connection state changes.
  final ValueChanged<LiveState>? onState;

  @override
  ConsumerState<LiveVideo> createState() => _LiveVideoState();
}

class _LiveVideoState extends ConsumerState<LiveVideo> {
  LiveState state = LiveState.connecting;
  LiveSource? source;
  RTCVideoRenderer? renderer;
  RTCPeerConnection? connection;
  Timer? clock;
  DateTime now = DateTime.now();
  int attempt = 0;

  @override
  void initState() {
    super.initState();
    unawaited(open());
  }

  @override
  void didUpdateWidget(LiveVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.id != widget.camera.id ||
        oldWidget.quality != widget.quality ||
        oldWidget.audio != widget.audio ||
        oldWidget.camera.online != widget.camera.online) {
      unawaited(close().then((_) => open()));
    }
  }

  @override
  void dispose() {
    unawaited(close());
    super.dispose();
  }

  void report(LiveState next) {
    if (!mounted) return;
    setState(() => state = next);
    widget.onState?.call(next);
  }

  Future<void> open() async {
    if (widget.camera.online == false) {
      report(LiveState.offline);
      return;
    }
    report(LiveState.connecting);
    final live = ref.read(backendProvider).live.live(widget.camera, quality: widget.quality, audio: widget.audio);
    source = live;
    final run = ++attempt;
    switch (live) {
      case SyntheticLive():
        clock = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => now = ref.read(clockProvider)());
        });
        now = ref.read(clockProvider)();
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (run == attempt) report(LiveState.playing);
      case WebRtcLive():
        await connect(live, run);
    }
  }

  Future<void> connect(WebRtcLive live, int run) async {
    try {
      final view = RTCVideoRenderer();
      await view.initialize();
      renderer = view;
      final pc = await createPeerConnection({'sdpSemantics': 'unified-plan', 'iceServers': <Object>[]});
      connection = pc;
      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
      if (widget.audio) {
        await pc.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        );
      }
      pc.onTrack = (event) {
        if (event.track.kind == 'video' && event.streams.isNotEmpty) {
          view.srcObject = event.streams.first;
        }
      };
      view.onFirstFrameRendered = () {
        if (run == attempt) report(LiveState.playing);
      };
      pc.onConnectionState = (value) {
        if (value == RTCPeerConnectionState.RTCPeerConnectionStateFailed && run == attempt) report(LiveState.failed);
      };
      final gathered = Completer<void>();
      pc.onIceGatheringState = (value) {
        if (value == RTCIceGatheringState.RTCIceGatheringStateComplete && !gathered.isCompleted) gathered.complete();
      };
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await gathered.future.timeout(const Duration(seconds: 2), onTimeout: () {});
      final local = await pc.getLocalDescription();
      final answer = await live.negotiate(local?.sdp ?? offer.sdp!);
      if (run != attempt) return;
      await pc.setRemoteDescription(RTCSessionDescription(answer, 'answer'));
      Timer(const Duration(seconds: 12), () {
        if (run == attempt && state == LiveState.connecting) report(LiveState.failed);
      });
    } catch (_) {
      if (run == attempt) report(LiveState.failed);
    }
  }

  Future<void> close() async {
    attempt++;
    clock?.cancel();
    clock = null;
    final pc = connection;
    final view = renderer;
    connection = null;
    renderer = null;
    try {
      await pc?.close();
      view?.srcObject = null;
      await view?.dispose();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final lenses = widget.camera.lenses;
    Widget picture;
    final current = source;
    if (current is SyntheticLive && state == LiveState.playing) {
      final full = Column(
        children: [
          for (final media in current.lenses) Expanded(child: SyntheticScene(media: media, clock: now)),
        ],
      );
      picture = widget.lens == null ? full : LensCrop(lens: widget.lens!, lenses: lenses, child: full);
    } else if (renderer != null && state != LiveState.failed) {
      final video = RTCVideoView(renderer!, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain);
      picture = widget.lens == null ? video : LensCrop(lens: widget.lens!, lenses: lenses, child: video);
    } else {
      picture = ColoredBox(color: p.frame, child: const SizedBox.expand());
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        picture,
        if (state == LiveState.playing) ?widget.overlay,
        if (state != LiveState.playing)
          Center(
            child: switch (state) {
              LiveState.connecting => Semantics(
                label: l10n.liveConnecting,
                child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              LiveState.failed => _Notice(
                icon: Icons.refresh_rounded,
                text: l10n.liveFailed,
                onTap: () => unawaited(close().then((_) => open())),
              ),
              LiveState.offline => _Notice(icon: Icons.videocam_off_outlined, text: l10n.liveCameraOffline),
              LiveState.playing => const SizedBox.shrink(),
            },
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xB3FFFFFF)),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Color(0xB3FFFFFF))),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(12), child: content),
    );
  }
}
