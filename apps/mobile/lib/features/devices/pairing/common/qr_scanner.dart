import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/tokens.dart';

/// A full screen QR scanner that reports the first code it reads.
class QrScanner extends ConsumerStatefulWidget {
  /// Creates a scanner.
  const QrScanner({super.key, required this.title, required this.hint, required this.onScanned, this.demoValue});

  /// The app bar title.
  final String title;

  /// What to point the camera at.
  final String hint;

  /// Called once with the scanned text.
  final ValueChanged<String> onScanned;

  /// A value a demo build can use instead of scanning.
  final String? demoValue;

  @override
  ConsumerState<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends ConsumerState<QrScanner> {
  bool done = false;

  void found(String value) {
    if (done || value.trim().isEmpty) return;
    done = true;
    widget.onScanned(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final demo = ref.watch(backendProvider).demo;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: const Color(0xFFFFFFFF),
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ReaderWidget(
              codeFormat: Format.qrCode,
              showGallery: false,
              showToggleCamera: false,
              tryHarder: true,
              cropPercent: 0.6,
              onScan: (code) {
                final text = code.text;
                if (code.isValid && text != null) found(text);
              },
            ),
          ),
          Positioned(
            left: Gaps.page,
            right: Gaps.page,
            bottom: Gaps.xl,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.hint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 15, height: 1.4),
                  ),
                  if (demo && widget.demoValue != null) ...[
                    const SizedBox(height: Gaps.md),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFFFFF),
                        side: const BorderSide(color: Color(0x80FFFFFF)),
                      ),
                      onPressed: () => found(widget.demoValue!),
                      child: Text(l10n.pairingDemoCode),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
