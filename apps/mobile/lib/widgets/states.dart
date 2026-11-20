import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/palette.dart';
import '../core/theme/theme.dart';
import '../l10n/l10n.dart';
import 'labels.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action, this.compact = false});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;
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

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry, this.compact = false});

  final Object error;
  final VoidCallback? onRetry;
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

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 6});

  final double? width;
  final double height;
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

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 6, this.thumbnail = true});

  final int rows;
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

class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final current = value;
    if (current.hasValue) return data(current.requireValue);
    if (current.hasError) return ErrorState(error: current.error!, onRetry: onRetry);
    return loading ?? const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showFailure(BuildContext context, Object error) => showMessage(context, context.l10n.failure(error));

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
