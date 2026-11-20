import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/analytics/presentation/analytics_screens.dart';
import 'package:smart_surveillance/features/analytics/presentation/labels.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';
import 'package:smart_surveillance/features/events/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
class RulesPainter extends CustomPainter {
  RulesPainter({
    required this.zones,
    required this.lines,
    required this.palette,
    this.selectedZone,
    this.selectedLine,
    this.thin = false,
    this.zonePoints,
    this.linePoints,
  });

  final List<Zone> zones;
  final List<Line> lines;
  final Palette palette;
  final int? selectedZone;
  final int? selectedLine;
  final bool thin;
  final List<List<Offset>>? zonePoints;
  final List<List<Offset>>? linePoints;

  final List<Rect> placed = [];
  Size area = Size.zero;

  Offset px(Offset point, Size size) => Offset(point.dx * size.width, point.dy * size.height);

  void label(Canvas canvas, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontFamily: sansFamily, fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final start = Rect.fromCenter(center: at, width: painter.width + 10, height: painter.height + 4);
    var box = start;
    // Move a label that would cover another one to the nearest free row inside the picture.
    for (final shift in const [1, -1, 2, -2]) {
      if (!placed.any(box.overlaps)) break;
      final moved = start.translate(0, shift * (start.height + 2));
      if (moved.top >= 0 && moved.bottom <= area.height) box = moved;
    }
    placed.add(box);
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = color.withValues(alpha: 0.85));
    painter.paint(canvas, box.topLeft + const Offset(5, 2));
  }

  void handles(Canvas canvas, List<Offset> points) {
    for (final p in points) {
      canvas.drawCircle(p, 9, Paint()..color = const Color(0x66000000));
      canvas.drawCircle(p, 7, Paint()..color = palette.focus);
      canvas.drawCircle(p, 3, Paint()..color = const Color(0xFFFFFFFF));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    placed.clear();
    area = size;
    final stroke = thin ? 1.5 : 2.2;
    for (var i = 0; i < zones.length; i++) {
      final zone = zones[i];
      final points = zonePoints?[i] ?? zone.polygon;
      final selected = selectedZone == i;
      final color = zone.suspended ? palette.warning : (selected ? palette.focus : const Color(0xFFFFFFFF));
      if (zone.wholeView) {
        final rect = (Offset.zero & size).deflate(stroke);
        canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.08));
        canvas.drawRect(
          rect,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke,
        );
        if (!thin) label(canvas, zone.name, Offset(size.width / 2, 16), color);
        continue;
      }
      if (points.isEmpty) continue;
      final first = px(points.first, size);
      final path = Path()..moveTo(first.dx, first.dy);
      for (final point in points.skip(1)) {
        final p = px(point, size);
        path.lineTo(p.dx, p.dy);
      }
      if (points.length > 2) path.close();
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: selected ? 0.16 : 0.1));
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: zone.enabled ? 1 : 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeJoin = StrokeJoin.round,
      );
      if (selected && !thin) handles(canvas, [for (final point in points) px(point, size)]);
      if (!thin && points.length > 2) {
        final center = points.fold(Offset.zero, (a, b) => a + b) / points.length.toDouble();
        label(canvas, zone.name, px(center, size), color);
      }
    }
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final points = linePoints?[i] ?? [line.a, line.b];
      final selected = selectedLine == i;
      final color = line.suspended ? palette.warning : (selected ? palette.focus : palette.person);
      if (points.isEmpty) continue;
      final a = px(points.first, size);
      if (points.length == 1) {
        canvas.drawCircle(a, 7, Paint()..color = color);
        continue;
      }
      final b = px(points[1], size);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = stroke + 0.6
          ..strokeCap = StrokeCap.round,
      );
      final along = (b - a) / max(1, (b - a).distance);
      final side = Offset(-(points[1].dy - points[0].dy) * size.width, (points[1].dx - points[0].dx) * size.height);
      final dot = side.dx * along.dx + side.dy * along.dy;
      var normal = side - along * dot;
      normal = normal / max(0.0001, normal.distance);
      final middle = (a + b) / 2;
      final length = thin ? 12.0 : 22.0;
      final wing = thin ? 4.0 : 6.0;
      void arrow(Offset direction) {
        final tip = middle + direction * length;
        final base = middle + direction * (length - (thin ? 5 : 8));
        final head = Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(base.dx + along.dx * wing, base.dy + along.dy * wing)
          ..lineTo(base.dx - along.dx * wing, base.dy - along.dy * wing)
          ..close();
        canvas.drawLine(
          middle,
          tip,
          Paint()
            ..color = color
            ..strokeWidth = stroke,
        );
        canvas.drawPath(head, Paint()..color = color);
      }

      if (line.direction != LineDirection.outward) arrow(normal);
      if (line.direction != LineDirection.inward) arrow(-normal);
      if (selected && !thin) handles(canvas, [a, b]);
      if (!thin) label(canvas, line.name, middle - normal * 18, color);
    }
  }

  @override
  bool shouldRepaint(RulesPainter oldDelegate) => true;
}

class DraftZone {
  DraftZone(this.zone, this.points);

  Zone zone;
  List<Offset> points;
}

class DraftLine {
  DraftLine(this.line, this.points);

  Line line;
  List<Offset> points;
}

class ZoneEditorScreen extends ConsumerStatefulWidget {
  const ZoneEditorScreen({super.key, required this.viewId});

  final String viewId;

  @override
  ConsumerState<ZoneEditorScreen> createState() => _ZoneEditorScreenState();
}

class _ZoneEditorScreenState extends ConsumerState<ZoneEditorScreen> {
  List<DraftZone>? zones;
  List<DraftLine>? lines;
  int? zone;
  int? line;
  bool adding = false;
  bool dirty = false;
  bool busy = false;
  int? dragging;

  void load(AnalyticsView view) {
    zones = [for (final z in view.zones) DraftZone(z, List.of(z.polygon))];
    lines = [
      for (final l in view.lines) DraftLine(l, [l.a, l.b]),
    ];
    zone = zones!.isNotEmpty ? 0 : null;
    line = zone == null && lines!.isNotEmpty ? 0 : null;
  }

  void touch(VoidCallback change) => setState(() {
    change();
    dirty = true;
  });

  void addZone() {
    final l10n = context.l10n;
    touch(() {
      zones!.add(DraftZone(Zone(name: '${l10n.editorZone} ${zones!.length + 1}', polygon: const []), []));
      zone = zones!.length - 1;
      line = null;
      adding = true;
    });
  }

  void addLine() {
    final l10n = context.l10n;
    touch(() {
      lines!.add(DraftLine(Line(name: '${l10n.editorLine} ${lines!.length + 1}', a: Offset.zero, b: Offset.zero), []));
      line = lines!.length - 1;
      zone = null;
      adding = true;
    });
  }

  Offset normalise(Offset local, Size size) =>
      Offset((local.dx / size.width).clamp(0.0, 1.0), (local.dy / size.height).clamp(0.0, 1.0));

  List<Offset>? get selectedPoints => zone != null ? zones![zone!].points : (line != null ? lines![line!].points : null);

  int? vertexAt(Offset local, Size size) {
    final points = selectedPoints;
    if (points == null) return null;
    for (var i = 0; i < points.length; i++) {
      final p = Offset(points[i].dx * size.width, points[i].dy * size.height);
      if ((p - local).distance < 28) return i;
    }
    return null;
  }

  bool inside(List<Offset> polygon, Offset point) {
    var result = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final a = polygon[i];
      final b = polygon[j];
      if ((a.dy > point.dy) != (b.dy > point.dy) && point.dx < (b.dx - a.dx) * (point.dy - a.dy) / (b.dy - a.dy) + a.dx) {
        result = !result;
      }
    }
    return result;
  }

  void tap(Offset local, Size size) {
    final point = normalise(local, size);
    if (adding) {
      if (zone != null) {
        touch(() => zones![zone!].points.add(point));
        HapticFeedback.selectionClick();
        return;
      }
      if (line != null) {
        touch(() {
          lines![line!].points.add(point);
          if (lines![line!].points.length >= 2) adding = false;
        });
        HapticFeedback.selectionClick();
        return;
      }
    }
    for (var i = 0; i < lines!.length; i++) {
      final points = lines![i].points;
      if (points.length < 2) continue;
      final a = Offset(points[0].dx * size.width, points[0].dy * size.height);
      final b = Offset(points[1].dx * size.width, points[1].dy * size.height);
      final ab = b - a;
      final t = ((local - a).dx * ab.dx + (local - a).dy * ab.dy) / max(1, ab.distanceSquared);
      final closest = a + ab * t.clamp(0.0, 1.0);
      if ((closest - local).distance < 24) {
        setState(() {
          line = i;
          zone = null;
        });
        return;
      }
    }
    for (var i = zones!.length - 1; i >= 0; i--) {
      if (zones![i].zone.wholeView || inside(zones![i].points, point)) {
        setState(() {
          zone = i;
          line = null;
        });
        return;
      }
    }
  }

  Future<void> save() async {
    final l10n = context.l10n;
    if (zones!.any((z) => !z.zone.wholeView && z.points.length < 3)) {
      showMessage(context, l10n.editorTooFewPoints);
      return;
    }
    setState(() => busy = true);
    try {
      await ref
          .read(backendProvider)
          .analytics
          .saveRules(
            widget.viewId,
            zones: [for (final z in zones!) z.zone.copyWith(polygon: z.zone.wholeView ? const [] : z.points)],
            lines: [
              for (final l in lines!.where((l) => l.points.length == 2)) l.line.copyWith(a: l.points[0], b: l.points[1]),
            ],
          );
      final site = ref.read(currentSiteProvider).value;
      if (site != null) ref.invalidate(viewsProvider(site.site.id));
      if (!mounted) return;
      setState(() => dirty = false);
      showMessage(context, l10n.editorSaved);
      Navigator.of(context).pop();
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final views = ref.watch(viewsProvider(site.site.id)).value;
    final view = views?.where((v) => v.id == widget.viewId).firstOrNull;
    if (view == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
    if (zones == null) load(view);
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (popped, _) async {
        if (popped) return;
        final leave = await confirm(context, title: l10n.editorDiscard, body: l10n.editorDiscardBody, action: l10n.commonClose);
        if (leave && context.mounted) {
          setState(() => dirty = false);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editorTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: Gaps.sm),
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(72, 40)),
                onPressed: busy ? null : save,
                child: busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: Gaps.xxl),
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: Gaps.page), child: canvas(context, view)),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
              child: Text(line != null ? l10n.editorHintLine : l10n.editorHintZone, style: context.text.bodySmall),
            ),
            shapes(context),
            if (zone != null)
              ZoneForm(key: ValueKey('zone$zone'), draft: zones![zone!], onChanged: (z) => touch(() => zones![zone!].zone = z)),
            if (line != null)
              LineForm(key: ValueKey('line$line'), draft: lines![line!], onChanged: (l) => touch(() => lines![line!].line = l)),
          ],
        ),
      ),
    );
  }

  Widget canvas(BuildContext context, AnalyticsView view) {
    final p = context.palette;
    final snapshot = ref.watch(viewSnapshotProvider(view.id)).value;
    return Frame(
      aspect: 16 / 9,
      radius: Radii.medium,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => tap(details.localPosition, size),
            onPanStart: (details) => setState(() => dragging = vertexAt(details.localPosition, size)),
            onPanUpdate: (details) {
              final index = dragging;
              final points = selectedPoints;
              if (index == null || points == null || index >= points.length) return;
              touch(() => points[index] = normalise(details.localPosition, size));
            },
            onPanEnd: (_) => setState(() => dragging = null),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MediaView(source: snapshot, showStamp: false),
                CustomPaint(
                  painter: RulesPainter(
                    zones: [for (final z in zones!) z.zone],
                    lines: [for (final l in lines!) l.line],
                    zonePoints: [for (final z in zones!) z.points],
                    linePoints: [for (final l in lines!) l.points],
                    selectedZone: zone,
                    selectedLine: line,
                    palette: p,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget shapes(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final points = selectedPoints;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 0),
            children: [
              for (var i = 0; i < zones!.length; i++) ...[
                ChoiceChip(
                  avatar: const Icon(Icons.pentagon_outlined, size: 16),
                  label: Text(zones![i].zone.name),
                  selected: zone == i,
                  onSelected: (_) => setState(() {
                    zone = i;
                    line = null;
                    adding = false;
                  }),
                ),
                const SizedBox(width: 8),
              ],
              for (var i = 0; i < lines!.length; i++) ...[
                ChoiceChip(
                  avatar: const Icon(Icons.timeline_rounded, size: 16),
                  label: Text(lines![i].line.name),
                  selected: line == i,
                  onSelected: (_) => setState(() {
                    line = i;
                    zone = null;
                    adding = false;
                  }),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(avatar: const Icon(Icons.add_rounded, size: 16), label: Text(l10n.editorAddZone), onPressed: addZone),
              const SizedBox(width: 8),
              ActionChip(avatar: const Icon(Icons.add_rounded, size: 16), label: Text(l10n.editorAddLine), onPressed: addLine),
            ],
          ),
        ),
        if (points != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.sm, Gaps.xs, Gaps.sm, 0),
            child: Row(
              children: [
                if (zone != null)
                  TextButton.icon(
                    onPressed: () => setState(() => adding = !adding),
                    icon: Icon(adding ? Icons.check_rounded : Icons.add_location_alt_outlined, size: 18),
                    label: Text(adding ? l10n.commonDone : l10n.editorAddPoints),
                  ),
                TextButton.icon(
                  onPressed: points.isEmpty ? null : () => touch(() => points.removeLast()),
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: Text(l10n.editorUndo),
                ),
                if (line != null)
                  TextButton.icon(
                    onPressed: points.length < 2 ? null : () => touch(() => lines![line!].points = points.reversed.toList()),
                    icon: const Icon(Icons.swap_vert_rounded, size: 18),
                    label: Text(l10n.editorFlip),
                  ),
                const Spacer(),
                IconButton(
                  tooltip: l10n.editorDelete,
                  color: p.dangerText,
                  onPressed: () => touch(() {
                    if (zone != null) {
                      zones!.removeAt(zone!);
                      zone = zones!.isEmpty ? null : 0;
                    } else if (line != null) {
                      lines!.removeAt(line!);
                      line = lines!.isEmpty ? null : 0;
                    }
                    adding = false;
                  }),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DurationPicker extends StatelessWidget {
  const DurationPicker({super.key, required this.label, required this.value, required this.options, required this.onChanged});

  final String label;
  final double value;
  final List<double> options;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String text(double s) => s <= 0
        ? l10n.editorDurationOff
        : (s >= 60 ? l10n.commonMinutesSeconds(s ~/ 60, (s % 60).round()) : l10n.commonSeconds(s.round()));
    return ListTile(
      title: Text(label),
      trailing: DropdownButton<double>(
        value: options.contains(value) ? value : null,
        hint: Text(text(value)),
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(Radii.medium),
        items: [for (final option in options) DropdownMenuItem(value: option, child: Text(text(option)))],
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

class LabelChips extends StatelessWidget {
  const LabelChips({super.key, required this.selected, required this.options, required this.onChanged});

  final List<String> selected;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final label in options)
          FilterChip(
            label: Text(l10n.label(label)),
            selected: selected.contains(label),
            onSelected: (on) => onChanged(on ? [...selected, label] : selected.where((l) => l != label).toList()),
          ),
      ],
    );
  }
}

class AlertPolicyField extends StatelessWidget {
  const AlertPolicyField({super.key, required this.policy, required this.onChanged});

  final AlertPolicy policy;
  final ValueChanged<AlertPolicy> onChanged;

  Future<String?> pickTime(BuildContext context, String value) async {
    final parts = value.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.tryParse(parts.first) ?? 22, minute: int.tryParse(parts.last) ?? 0),
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final window = policy.schedule.isEmpty ? const TimeWindow(start: '22:00', end: '07:00') : policy.schedule.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AlertMode>(
            showSelectedIcon: false,
            segments: [for (final mode in AlertMode.values) ButtonSegment(value: mode, label: Text(l10n.alertMode(mode)))],
            selected: {policy.mode},
            onSelectionChanged: (value) => onChanged(
              policy.copyWith(mode: value.first, schedule: value.first == AlertMode.schedule ? [window] : policy.schedule),
            ),
          ),
        ),
        if (policy.mode == AlertMode.schedule)
          Padding(
            padding: const EdgeInsets.only(top: Gaps.sm),
            child: Row(
              children: [
                Expanded(child: Text(l10n.editorAlertHours(window.start, window.end), style: context.text.bodyMedium)),
                TextButton(
                  onPressed: () async {
                    final start = await pickTime(context, window.start);
                    if (start == null || !context.mounted) return;
                    final end = await pickTime(context, window.end);
                    if (end == null) return;
                    onChanged(policy.copyWith(schedule: [window.copyWith(start: start, end: end)]));
                  },
                  child: Text(l10n.commonEdit),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ZoneForm extends StatefulWidget {
  const ZoneForm({super.key, required this.draft, required this.onChanged});

  final DraftZone draft;
  final ValueChanged<Zone> onChanged;

  @override
  State<ZoneForm> createState() => _ZoneFormState();
}

class _ZoneFormState extends State<ZoneForm> {
  late final name = TextEditingController(text: widget.draft.zone.name);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final zone = widget.draft.zone;
    void set(Zone next) => widget.onChanged(next);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: TextField(
            controller: name,
            decoration: InputDecoration(labelText: l10n.editorNameZone),
            onChanged: (value) => set(zone.copyWith(name: value)),
          ),
        ),
        const SizedBox(height: Gaps.sm),
        TileGroup(
          children: [
            SwitchListTile(title: Text(l10n.editorEnabled), value: zone.enabled, onChanged: (v) => set(zone.copyWith(enabled: v))),
            SwitchListTile(
              title: Text(l10n.analyticsWholeView),
              value: zone.wholeView,
              onChanged: (v) => set(zone.copyWith(wholeView: v)),
            ),
          ],
        ),
        SectionHeader(l10n.editorObjects),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: LabelChips(selected: zone.labels, options: detectionLabels, onChanged: (v) => set(zone.copyWith(labels: v))),
        ),
        SectionHeader(l10n.editorAlerts),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: AlertPolicyField(policy: zone.alert, onChanged: (v) => set(zone.copyWith(alert: v))),
        ),
        const SizedBox(height: Gaps.md),
        TileGroup(
          children: [
            DurationPicker(
              label: l10n.editorDwell,
              value: zone.minDwell,
              options: const [0, 1, 2, 5, 10, 30],
              onChanged: (v) => set(zone.copyWith(minDwell: v)),
            ),
            DurationPicker(
              label: l10n.editorLoiter,
              value: zone.loiterSeconds,
              options: const [0, 30, 60, 120, 300, 600],
              onChanged: (v) => set(zone.copyWith(loiterSeconds: v)),
            ),
            ListTile(
              title: Text(l10n.editorCrowd),
              trailing: DropdownButton<int>(
                value: zone.crowdCount,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(Radii.medium),
                items: [
                  for (final n in const [0, 2, 3, 4, 5, 8, 10]) DropdownMenuItem(value: n, child: Text(l10n.editorCrowdPeople(n))),
                ],
                onChanged: (v) => set(zone.copyWith(crowdCount: v ?? 0)),
              ),
            ),
            ListTile(
              title: Text(l10n.editorAnimals),
              trailing: DropdownButton<AnimalMode>(
                value: zone.animals,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(Radii.medium),
                items: [for (final m in AnimalMode.values) DropdownMenuItem(value: m, child: Text(l10n.animalMode(m)))],
                onChanged: (v) => set(zone.copyWith(animals: v ?? AnimalMode.record)),
              ),
            ),
          ],
        ),
        SectionHeader(l10n.kindObjectLeft),
        TileGroup(
          children: [
            DurationPicker(
              label: l10n.editorLeft,
              value: zone.leftSeconds,
              options: const [0, 60, 300, 600, 900, 1800],
              onChanged: (v) => set(zone.copyWith(leftSeconds: v)),
            ),
            DurationPicker(
              label: l10n.editorTaken,
              value: zone.takenSeconds,
              options: const [0, 300, 900, 1800, 3600],
              onChanged: (v) => set(zone.copyWith(takenSeconds: v)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.xs, Gaps.page, Gaps.md),
              child: LabelChips(
                selected: zone.objectLabels,
                options: objectLabels,
                onChanged: (v) => set(zone.copyWith(objectLabels: v)),
              ),
            ),
          ],
        ),
        if (zone.suspended)
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.md, Gaps.page, 0),
            child: Text(l10n.analyticsSuspended, style: context.text.bodySmall?.copyWith(color: p.warning)),
          ),
      ],
    );
  }
}

class LineForm extends StatefulWidget {
  const LineForm({super.key, required this.draft, required this.onChanged});

  final DraftLine draft;
  final ValueChanged<Line> onChanged;

  @override
  State<LineForm> createState() => _LineFormState();
}

class _LineFormState extends State<LineForm> {
  late final name = TextEditingController(text: widget.draft.line.name);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final line = widget.draft.line;
    void set(Line next) => widget.onChanged(next);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
          child: TextField(
            controller: name,
            decoration: InputDecoration(labelText: l10n.editorNameLine),
            onChanged: (value) => set(line.copyWith(name: value)),
          ),
        ),
        const SizedBox(height: Gaps.sm),
        TileGroup(
          children: [
            SwitchListTile(title: Text(l10n.editorEnabled), value: line.enabled, onChanged: (v) => set(line.copyWith(enabled: v))),
          ],
        ),
        SectionHeader(l10n.editorDirection),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<LineDirection>(
              showSelectedIcon: false,
              segments: [for (final d in LineDirection.values) ButtonSegment(value: d, label: Text(l10n.direction(d)))],
              selected: {line.direction},
              onSelectionChanged: (value) => set(line.copyWith(direction: value.first)),
            ),
          ),
        ),
        SectionHeader(l10n.editorObjects),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: LabelChips(selected: line.labels, options: detectionLabels, onChanged: (v) => set(line.copyWith(labels: v))),
        ),
        SectionHeader(l10n.editorAlerts),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
          child: AlertPolicyField(policy: line.alert, onChanged: (v) => set(line.copyWith(alert: v))),
        ),
      ],
    );
  }
}
