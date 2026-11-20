import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';

/// A bordered card that holds [child] and is tappable when [onTap] is set.
class Panel extends StatelessWidget {
  /// Creates a panel around [child] with the given [padding] and fill [color].
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gaps.lg),
    this.onTap,
    this.color,
  });

  /// The content of the panel.
  final Widget child;

  /// The space between the border and [child].
  final EdgeInsetsGeometry padding;

  /// The callback for taps, or null when the panel is not tappable.
  final VoidCallback? onTap;

  /// The fill colour, defaulting to the surface colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Padding(padding: padding, child: child);
    return Material(
      color: color ?? p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.large),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

/// A small heading above a group of content, with an optional widget at its end.
class SectionHeader extends StatelessWidget {
  /// Creates a heading with [title] and an optional [action].
  const SectionHeader(this.title, {super.key, this.action, this.padding});

  /// The heading text.
  final String title;

  /// The widget shown at the end of the heading, such as a button.
  final Widget? action;

  /// The padding around the heading, defaulting to the standard section spacing.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? const EdgeInsets.fromLTRB(Gaps.page, Gaps.xl, Gaps.page, Gaps.sm),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: context.text.titleSmall?.copyWith(color: context.palette.text2),
            ),
          ),
        ),
        ?action,
      ],
    ),
  );
}

/// The colour treatment of a [Tag].
enum TagTone {
  /// A plain grey tag.
  neutral,

  /// A red tag for alerts and errors.
  alert,

  /// A green tag for success.
  ok,

  /// An amber tag for warnings.
  warning,

  /// A blue tag for information.
  info,

  /// A dimmed tag for secondary information.
  muted,
}

/// A small rounded label such as a status or kind.
class Tag extends StatelessWidget {
  /// Creates a tag showing [text] in the colour of [tone].
  const Tag(this.text, {super.key, this.tone = TagTone.neutral, this.icon, this.dense = false});

  /// The text of the tag.
  final String text;

  /// The colour treatment of the tag.
  final TagTone tone;

  /// The icon shown before the text, if any.
  final IconData? icon;

  /// Whether the tag is drawn smaller.
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
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
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

/// A small circle showing whether something is online.
class StatusDot extends StatelessWidget {
  /// Creates a dot of [size] for [online]: green when true, red when false, grey when unknown.
  const StatusDot({super.key, required this.online, this.size = 8});

  /// Whether the item is online, or null when its state is unknown.
  final bool? online;

  /// The diameter of the dot.
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

/// A card showing one headline value with a label, such as a count or uptime.
class MetricTile extends StatelessWidget {
  /// Creates a tile showing [value] under [label].
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.tone,
    this.onTap,
    this.icon,
  });

  /// The name of the measurement.
  final String label;

  /// The headline value.
  final String value;

  /// A line of extra context under the value.
  final String? detail;

  /// The colour of the value, defaulting to the text colour.
  final Color? tone;

  /// The callback for taps, or null when the tile is not tappable.
  final VoidCallback? onTap;

  /// The icon shown beside the label.
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
                child: Text(
                  label,
                  style: context.text.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: dataStyle(context, size: 26, weight: FontWeight.w500, color: tone ?? p.text),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail!,
              style: context.text.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// A row with a muted label at the start and its value at the end.
class ReadOut extends StatelessWidget {
  /// Creates a row showing [value] for [label], in the data font when [mono] is true.
  const ReadOut({super.key, required this.label, required this.value, this.mono = false});

  /// The name of the value.
  final String label;

  /// The value shown at the end of the row.
  final String value;

  /// Whether the value uses the monospace data font.
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: context.text.bodyMedium?.copyWith(color: context.palette.text3),
          ),
        ),
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

/// A rounded, bordered card that stacks [children] with dividers between them.
class TileGroup extends StatelessWidget {
  /// Creates a group of [children] with the given outer [margin].
  const TileGroup({super.key, required this.children, this.margin});

  /// The rows to stack, usually list tiles.
  final List<Widget> children;

  /// The space around the group, defaulting to the page margins.
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.large),
          side: BorderSide(color: p.border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

/// A rounded square holding an icon.
class IconBadge extends StatelessWidget {
  /// Creates a badge showing [icon] at [size].
  const IconBadge({super.key, required this.icon, this.color, this.size = 36});

  /// The icon to show.
  final IconData icon;

  /// The icon colour, defaulting to the secondary text colour.
  final Color? color;

  /// The width and height of the badge.
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(Radii.medium),
        border: Border.all(color: p.border),
      ),
      child: Icon(icon, size: size * 0.5, color: color ?? p.text2),
    );
  }
}

/// A numbered step with explanatory text.
class Bullet extends StatelessWidget {
  /// Creates a step numbered [number] with [text].
  const Bullet({super.key, required this.number, required this.text});

  /// The number shown in the circle.
  final int number;

  /// The text of the step.
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
          Expanded(
            child: Text(text, style: context.text.bodyMedium?.copyWith(color: p.text2)),
          ),
        ],
      ),
    );
  }
}
