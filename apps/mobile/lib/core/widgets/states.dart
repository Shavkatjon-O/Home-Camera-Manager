import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/failure_labels.dart';
/// A centred icon, title and optional text and button, shown when there is nothing to display.
class EmptyState extends StatelessWidget {
  /// Creates an empty state with [icon] and [title].
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action, this.compact = false});

  /// The icon shown in the rounded square above the title.
  final IconData icon;
  /// The headline of the message.
  final String title;
  /// The explanation shown under the title.
  final String? body;
  /// The widget shown under the text, usually a button.
  final Widget? action;
  /// Whether to use less vertical padding.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Gaps.xxl, vertical: compact ? Gaps.xl : Gaps.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(Radii.large),
                border: Border.all(color: p.border),
              ),
              child: Icon(icon, color: p.text2, size: 26),
            ),
            const SizedBox(height: Gaps.lg),
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: Gaps.sm),
              Text(body!, style: context.text.bodyMedium?.copyWith(color: p.text2), textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: Gaps.xl), action!],
          ],
        ),
      ),
    );
  }
}

/// An [EmptyState] that explains a failure and offers to retry.
class ErrorState extends StatelessWidget {
  /// Creates a state describing [error], with a retry button when [onRetry] is given.
  const ErrorState({super.key, required this.error, this.onRetry, this.compact = false});

  /// The failure to describe.
  final Object error;
  /// The callback for the retry button, or null to hide the button.
  final VoidCallback? onRetry;
  /// Whether to use less vertical padding.
  final bool compact;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.cloud_off_outlined,
    title: context.l10n.errorTitle,
    body: context.l10n.failure(error),
    compact: compact,
    action: onRetry == null
        ? null
        : OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.commonRetry),
          ),
  );
}

/// A grey placeholder block that pulses while content loads.
class Skeleton extends StatefulWidget {
  /// Creates a placeholder of the given [width], [height] and corner [radius].
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 6});

  /// The width of the block, or null to fill the available width.
  final double? width;
  /// The height of the block.
  final double height;
  /// The corner radius of the block.
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(p.surface2, p.surface3, reduce ? 0.4 : controller.value * 0.8),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A list of placeholder rows shown while a list loads.
class ListSkeleton extends StatelessWidget {
  /// Creates a skeleton of [rows] rows, each with a thumbnail when [thumbnail] is true.
  const ListSkeleton({super.key, this.rows = 6, this.thumbnail = true});

  /// The number of placeholder rows.
  final int rows;
  /// Whether each row has a picture placeholder.
  final bool thumbnail;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.commonLoading,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.page, vertical: 10),
        child: Row(
          children: [
            if (thumbnail) ...[const Skeleton(width: 96, height: 56, radius: 8), const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 140 + (index % 3) * 30.0),
                  const SizedBox(height: 8),
                  const Skeleton(width: 90, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A widget that shows an [AsyncValue] as its data, a loading indicator or an error with retry.
class AsyncBody<T> extends StatelessWidget {
  /// Creates a body that builds [data] from [value] once it has loaded.
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  /// The value to show.
  final AsyncValue<T> value;
  /// The builder of the content from the loaded value.
  final Widget Function(T data) data;
  /// The widget shown while loading, defaulting to a spinner.
  final Widget? loading;
  /// The callback for the retry button of the error state.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final current = value;
    if (current.hasValue) return data(current.requireValue);
    if (current.hasError) return ErrorState(error: current.error!, onRetry: onRetry);
    return loading ?? const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

/// Shows [message] in a snack bar, replacing any snack bar already showing.
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Shows a snack bar describing [error].
void showFailure(BuildContext context, Object error) => showMessage(context, context.l10n.failure(error));

/// Asks the user to confirm with a dialog and returns true when they choose [action].
Future<bool> confirm(
  BuildContext context, {
  required String title,
  String? body,
  required String action,
  bool destructive = false,
}) async {
  final p = context.palette;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: p.danger, foregroundColor: const Color(0xFFFFFFFF))
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}
