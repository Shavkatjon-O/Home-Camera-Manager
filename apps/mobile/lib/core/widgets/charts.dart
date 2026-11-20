import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
/// Inward and outward counts for a run of time buckets, ready to chart.
class CountsSeries {
  /// Creates a series from per-bucket [labels], [inward] counts and [outward] counts.
  const CountsSeries({required this.labels, required this.inward, required this.outward});

  /// The label of each bucket, such as the hour or day.
  final List<String> labels;
  /// The number of objects that crossed inward in each bucket.
  final List<int> inward;
  /// The number of objects that crossed outward in each bucket.
  final List<int> outward;

  /// Returns the total inward count over all buckets.
  int get totalIn => inward.fold(0, (a, b) => a + b);

  /// Returns the total outward count over all buckets.
  int get totalOut => outward.fold(0, (a, b) => a + b);

  /// Returns the index of the bucket with the most crossings in both directions.
  int get peak {
    var best = 0;
    for (var i = 1; i < inward.length; i++) {
      if (inward[i] + outward[i] > inward[best] + outward[best]) best = i;
    }
    return best;
  }
}

/// A bar chart of inward and outward counts per bucket.
class CountsChart extends StatelessWidget {
  /// Creates a chart of [series], [height] logical pixels tall.
  const CountsChart({
    super.key,
    required this.series,
    this.height = 180,
    this.showOut = true,
    this.labelEvery = 3,
    this.semanticLabel,
  });

  /// The counts to draw.
  final CountsSeries series;
  /// The height of the chart.
  final double height;
  /// Whether the outward bars are drawn beside the inward ones.
  final bool showOut;
  /// How many buckets apart the labels under the bars are shown.
  final int labelEvery;
  /// The description read out by screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final count = series.labels.length;
    final top = [for (var i = 0; i < count; i++) max(series.inward[i], showOut ? series.outward[i] : 0)].fold(0, max);
    final ceiling = max(4, (top * 1.15).ceil()).toDouble();
    final rodWidth = count > 16 ? (showOut ? 3.5 : 6.0) : (showOut ? 7.0 : 12.0);
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: BarChart(
          BarChartData(
            maxY: ceiling,
            minY: 0,
            alignment: BarChartAlignment.spaceBetween,
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: max(1, (ceiling / 4).ceilToDouble()),
              getDrawingHorizontalLine: (value) => FlLine(color: p.border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: max(1, (ceiling / 4).ceilToDouble()),
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(value.toInt().toString(), style: dataStyle(context, size: 10, color: p.text3)),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= count || index % labelEvery != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(series.labels[index], style: dataStyle(context, size: 10, color: p.text3)),
                    );
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => p.surface3,
                tooltipBorderRadius: BorderRadius.circular(Radii.small),
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '${series.labels[group.x]}  ${rod.toY.toInt()}',
                  dataStyle(context, size: 11.5),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < count; i++)
                BarChartGroupData(
                  x: i,
                  barsSpace: 2,
                  barRods: [
                    BarChartRodData(
                      toY: series.inward[i].toDouble(),
                      color: p.text,
                      width: rodWidth,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(rodWidth / 2.5)),
                    ),
                    if (showOut)
                      BarChartRodData(
                        toY: series.outward[i].toDouble(),
                        color: p.text3.withValues(alpha: 0.65),
                        width: rodWidth,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(rodWidth / 2.5)),
                      ),
                  ],
                ),
            ],
          ),
          duration: const Duration(milliseconds: 250),
        ),
      ),
    );
  }
}

/// A legend naming the two bar colours of [CountsChart].
class ChartLegend extends StatelessWidget {
  /// Creates a legend with the given labels.
  const ChartLegend({super.key, required this.inLabel, required this.outLabel});

  /// The label of the inward bars.
  final String inLabel;
  /// The label of the outward bars.
  final String outLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget item(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(text, style: context.text.labelMedium),
      ],
    );
    return Wrap(
      spacing: 16,
      children: [item(p.text, inLabel), item(p.text3.withValues(alpha: 0.65), outLabel)],
    );
  }
}

/// A row of thin bars showing a value between 0 and 1 over time, coloured by how low it is.
class Sparkline extends StatelessWidget {
  /// Creates a sparkline of [values], [height] tall, where null marks a bucket with no data.
  const Sparkline({super.key, required this.values, this.height = 28, this.color});

  /// The value of each bucket from 0 to 1, or null when there is no data.
  final List<double?> values;
  /// The height of the tallest bar.
  final double height;
  /// The colour of healthy bars, defaulting to the success colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final value in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.75),
                child: Container(
                  height: value == null ? 3 : max(3, height * value),
                  decoration: BoxDecoration(
                    color: value == null
                        ? p.surface3
                        : (value < 0.5 ? p.error : (value < 0.97 ? p.warning : (color ?? p.ok))),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
