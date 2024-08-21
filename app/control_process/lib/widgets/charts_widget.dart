import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartsWidget extends StatelessWidget {
  ChartsWidget({
    super.key,
    required this.data,
    required this.height,
    required this.maxValue,
    required this.minValue,
    required this.maxTime,
  });

  final Map<int, double> data;
  final double height;
  final List<FlSpot> spots = [];
  final double maxValue;
  final double minValue;
  final int maxTime;

  @override
  Widget build(BuildContext context) {
    data.forEach(
      (key, value) => spots.add(FlSpot(key.toDouble() * 0.01, value)),
    );
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        bottom: 12,
        right: 20,
        top: 20,
      ),
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.width / height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    maxContentWidth: 100,
                    getTooltipColor: (touchedSpot) => Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final textStyle =
                            Theme.of(context).textTheme.labelLarge!;
                        return LineTooltipItem(
                          '${touchedSpot.x.toStringAsFixed(3)}, ${touchedSpot.y.toStringAsFixed(3)}',
                          textStyle,
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                  getTouchLineStart: (data, index) => 0,
                ),
                lineBarsData: [
                  LineChartBarData(
                    color: Theme.of(context).sliderTheme.activeTrackColor,
                    spots: spots,
                    isCurved: false,
                    isStrokeCapRound: false,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
                minY: minValue,
                maxY: maxValue,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // ignore: unused_local_variable
                        final chartWidth = constraints.maxWidth;
                        final style = Theme.of(context).textTheme.bodyLarge;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 16,
                          child: Text(meta.formattedValue, style: style),
                        );
                      },
                      reservedSize: 100,
                    ),
                    drawBelowEverything: true,
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // final chartWidth = constraints.maxWidth;
                        // if (value % 1 != 0) {
                        //   return Container();
                        // }
                        final style = Theme.of(context).textTheme.bodyLarge;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 16,
                          child: Text(meta.formattedValue, style: style),
                        );
                      },
                      reservedSize: 48,
                      interval: 1,
                    ),
                    drawBelowEverything: true,
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  checkToShowHorizontalLine: (value) {
                    return value.toInt() == 0;
                  },
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).sliderTheme.activeTrackColor,
                    dashArray: [1, 1],
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
