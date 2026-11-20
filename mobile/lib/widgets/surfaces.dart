import 'package:flutter/material.dart';

import '../core/theme/palette.dart';
import '../core/theme/theme.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(Gaps.lg), this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Padding(padding: padding, child: child);
    return Material(
      color: color ?? p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large), side: BorderSide(color: p.border)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.padding});

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? const EdgeInsets.fromLTRB(Gaps.page, Gaps.xl, Gaps.page, Gaps.sm),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.text.titleSmall?.copyWith(color: context.palette.text2)),
          ),
        ),
        ?action,
      ],
    ),
  );
}

enum TagTone { neutral, alert, ok, warning, info, muted }

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.tone = TagTone.neutral, this.icon, this.dense = false});

  final String text;
  final TagTone tone;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (bg, fg) = switch (tone) {
      TagTone.neutral => (p.chip, p.text2),
      TagTone.alert => (p.error.withValues(alpha: 0.14), p.dangerText),
      TagTone.ok => (p.ok.withValues(alpha: 0.14), p.ok),
      TagTone.warning => (p.warning.withValues(alpha: 0.16), p.warning),
      TagTone.info => (p.focus.withValues(alpha: 0.14), p.focus),
      TagTone.muted => (p.chip, p.text3),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 6 : 8, vertical: dense ? 2 : 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.small)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: fg), const SizedBox(width: 4)],
          Text(
            text,
            style: TextStyle(
              fontFamily: monoFamily,
              fontSize: dense ? 10.5 : 11.5,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.online, this.size = 8});

  final bool? online;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = online == true ? p.ok : (online == false ? p.error : p.off);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({super.key, required this.label, required this.value, this.detail, this.tone, this.onTap, this.icon});

  final String label;
  final String value;
  final String? detail;
  final Color? tone;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: p.text3), const SizedBox(width: 6)],
              Expanded(
                child: Text(label, style: context.text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: dataStyle(context, size: 26, weight: FontWeight.w500, color: tone ?? p.text)),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

class ReadOut extends StatelessWidget {
  const ReadOut({super.key, required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 118, child: Text(label, style: context.text.bodyMedium?.copyWith(color: context.palette.text3))),
        Expanded(
          child: Text(
            value,
            style: mono ? dataStyle(context, size: 13.5) : context.text.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(Divider(height: 1, indent: Gaps.page, color: p.border));
      items.add(children[i]);
    }
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: Gaps.page),
      child: Material(
        color: p.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.large), side: BorderSide(color: p.border)),
        child: Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.color, this.size = 36});

  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(Radii.medium), border: Border.all(color: p.border)),
      child: Icon(icon, size: size * 0.5, color: color ?? p.text2),
    );
  }
}

class Bullet extends StatelessWidget {
  const Bullet({super.key, required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surface3, shape: BoxShape.circle),
            child: Text('$number', style: dataStyle(context, size: 12, weight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: context.text.bodyMedium?.copyWith(color: p.text2))),
        ],
      ),
    );
  }
}
