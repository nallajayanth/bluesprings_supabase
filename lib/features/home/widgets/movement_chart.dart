import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/dashboard_models.dart';

class MovementChart extends StatefulWidget {
  final List<WeeklyData> data;

  const MovementChart({super.key, required this.data});

  @override
  State<MovementChart> createState() => _MovementChartState();
}

class _MovementChartState extends State<MovementChart> {
  bool isEntryMode = true; // Toggle between Entry and Exit
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 600;
              
              Widget titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: const EdgeInsets.only(left: 12),
                     decoration: const BoxDecoration(
                       border: Border(left: BorderSide(color: AppColors.navBarBlue, width: 4)),
                     ),
                     child: const Text(
                      'Traffic Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                     ),
                   ),
                   const SizedBox(height: 4),
                   const Padding(
                     padding: EdgeInsets.only(left: 16.0),
                     child: Text(
                      'Hourly flow analytics per vehicle class',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                     ),
                   ),
                ],
              );
              
              Widget controlsSection = Row(
                mainAxisSize: MainAxisSize.min, // Wrap content
                children: [
                  _buildModeButton('Entry', true, AppColors.cardGreen),
                  const SizedBox(width: 8),
                  _buildModeButton('Exit', false, AppColors.cardRed),
                  const SizedBox(width: 16),
                  Flexible(child: _buildLegendBadge('2W', AppColors.cardBlue)), 
                  const SizedBox(width: 8),
                  Flexible(child: _buildLegendBadge('4W', AppColors.cardCyan)), 
                ],
              );

              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: controlsSection
                    ),
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    titleSection,
                    controlsSection,
                  ],
                );
              }
            },
          ),
          
          const SizedBox(height: 30),
          
          // Chart
          AspectRatio(
            aspectRatio: 1.70,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30, // Adjusted Max Y for demo
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String weekDay = widget.data[group.x.toInt()].day;
                      String type = rodIndex == 0 ? '2-Wheelers' : '4-Wheelers';
                      return BarTooltipItem(
                        '$weekDay\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$type: ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: rod.toY.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < widget.data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              widget.data[value.toInt()].day,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                         if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: widget.data.asMap().entries.map((e) {
                   // Based on isEntryMode, pick data
                   final data = e.value;
                   final val2W = isEntryMode ? data.entry2W.toDouble() : data.exit2W.toDouble();
                   final val4W = isEntryMode ? data.entry4W.toDouble() : data.exit4W.toDouble();

                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: val2W,
                        color: AppColors.cardBlue, // 2W Color
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: val4W,
                        color: AppColors.cardCyan, // 4W Color
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                    barsSpace: 4, // Space between 2W and 4W bars
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isEntry, Color color) {
     final bool isSelected = isEntryMode == isEntry;
     return InkWell(
       onTap: () {
         setState(() {
           isEntryMode = isEntry;
         });
       },
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         decoration: BoxDecoration(
           color: isSelected ? color : Colors.transparent,
           border: Border.all(color: color), // Always colored border
           borderRadius: BorderRadius.circular(6),
         ),
         child: Row(
            children: [
               Icon(
                 isEntry ? Icons.login : Icons.logout,
                 size: 16,
                 color: isSelected ? Colors.white : color,
               ),
               const SizedBox(width: 4),
               Text(
                 label,
                 style: TextStyle(
                   color: isSelected ? Colors.white : color,
                   fontWeight: FontWeight.bold,
                   fontSize: 13,
                 ),
               ),
            ],
         ),
       ),
     );
  }

  Widget _buildLegendBadge(String label, Color color) {
     return Container(
         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
         decoration: BoxDecoration(
           color: color,
           borderRadius: BorderRadius.circular(6),
           boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0,2))],
         ),
         child: Row(
            children: [
               Icon(
                 label == '2W' ? Icons.two_wheeler : Icons.directions_car,
                 size: 16,
                 color: Colors.white,
               ),
               const SizedBox(width: 4),
               Text(
                 label,
                 style: const TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.bold,
                   fontSize: 13,
                 ),
               ),
            ],
         ),
     );
  }
}
