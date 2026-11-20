import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/pairing/common/camera_details.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// The parts of an RTSP stream link.
class RtspLink {
  /// Creates a parsed link.
  const RtspLink({
    required this.host,
    required this.port,
    required this.path,
    this.username,
    this.password,
  });

  /// The camera's host.
  final String host;

  /// The RTSP port, 554 when the link has none.
  final int port;

  /// The stream path with its query.
  final String path;

  /// The username in the link, if any.
  final String? username;

  /// The password in the link, if any.
  final String? password;

  /// Parses [text], or returns null when it is not an rtsp or rtsps link.
  static RtspLink? parse(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null || (uri.scheme != 'rtsp' && uri.scheme != 'rtsps') || uri.host.isEmpty) {
      return null;
    }
    final info = uri.userInfo.split(':');
    final path = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    return RtspLink(
      host: uri.host,
      port: uri.hasPort ? uri.port : 554,
      path: path.isEmpty ? '/' : path,
      username: uri.userInfo.isEmpty ? null : Uri.decodeComponent(info.first),
      password: info.length > 1 ? Uri.decodeComponent(info.sublist(1).join(':')) : null,
    );
  }
}

/// Adds a camera from a pasted RTSP link.
class RtspUrlScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const RtspUrlScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<RtspUrlScreen> createState() => _RtspUrlScreenState();
}

class _RtspUrlScreenState extends ConsumerState<RtspUrlScreen> {
  final form = GlobalKey<FormState>();
  final url = TextEditingController();

  @override
  void dispose() {
    url.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (!form.currentState!.validate()) return;
    final link = RtspLink.parse(url.text)!;
    final navigator = Navigator.of(context);
    widget.session.step('link');
    final camera = DiscoveredCamera(
      id: 'rtsp-${link.host}-${link.port}${link.path}',
      host: link.host,
      ports: [link.port],
      brand: CameraBrand.rtsp,
      model: link.host,
      rtspPort: link.port,
      mainPath: link.path,
      foundBy: 'rtsp_url',
    );
    final result = await navigator.push<PairingResult>(
      MaterialPageRoute(
        builder: (_) => CameraDetailsScreen(
          pairing: widget.pairing,
          session: widget.session,
          camera: camera,
          initialUser: link.username,
          initialPassword: link.password,
        ),
      ),
    );
    if (result != null) navigator.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FlowScaffold(
      title: l10n.rtspTitle,
      subtitle: l10n.rtspBody,
      bottom: SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: next, child: Text(l10n.commonNext)),
      ),
      children: [
        Form(
          key: form,
          child: TextFormField(
            controller: url,
            autofocus: true,
            keyboardType: TextInputType.url,
            autocorrect: false,
            maxLines: 3,
            minLines: 1,
            style: dataStyle(context, size: 14),
            decoration: InputDecoration(
              labelText: l10n.rtspField,
              hintText: 'rtsp://192.168.1.64:554/stream1',
            ),
            validator: (value) => RtspLink.parse(value ?? '') == null ? l10n.rtspInvalid : null,
          ),
        ),
      ],
    );
  }
}
