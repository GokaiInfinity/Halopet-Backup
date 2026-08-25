import re

def process():
    with open('lib/features/admin/admin_dashboard_screens.dart', 'r', encoding='utf-8') as f:
        dash = f.read()

    with open('lib/features/admin/admin_system_screens.dart', 'r', encoding='utf-8') as f:
        report = f.read()

    # 1. Remove _chartTabIndex from dashboard
    dash = re.sub(r'(\s*int _chartTabIndex = 1;.*?)\n', '\n', dash)

    # Extract _buildAdaptiveChartSection
    chart_section_match = re.search(r'Widget _buildAdaptiveChartSection\(\) \{.*?(?=^\s*Widget _chartPill|^\s*\})', dash, re.DOTALL | re.MULTILINE)
    
    if not chart_section_match:
        print("Could not find chart section")
        return
        
    chart_section = chart_section_match.group(0)
    
    # We will rewrite the dashboard's chart section manually below
    new_dash_chart_section = """Widget _buildAdaptiveChartSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getAdminChartData(
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];
        double maxConsultations = 1;
        
        for (var row in data) {
          final c = (row['total_consultations'] as num?)?.toDouble() ?? 0;
          if (c > maxConsultations) maxConsultations = c;
        }

        final consultationBars = <BarChartGroupData>[];
        for (int i = 0; i < data.length; i++) {
          final consultations =
              (data[i]['total_consultations'] as num?)?.toDouble() ?? 0;
          consultationBars.add(BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: consultations,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 14,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          ));
        }

        Widget bottomLabel(double value, TitleMeta meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
          final parts = (data[idx]['date'] as String).split('-');
          if (parts.length != 3) return const SizedBox.shrink();
          if (data.length > 8 &&
              idx != 0 &&
              idx != data.length - 1 &&
              idx % (data.length ~/ 4) != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 6,
            child: Text('${parts[2]}/${parts[1]}',
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E9F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grafik Konsultasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2646),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 190,
                child: data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada data pada periode ini',
                              style: TextStyle(
                                  color: Color(0xFF7A93AA), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : BarChart(
                        BarChartData(
                          maxY: maxConsultations * 1.3,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) =>
                                  const Color(0xFF0F2646),
                              getTooltipItem:
                                  (group, gi, rod, ri) => BarTooltipItem(
                                '${rod.toY.toInt()} konsultasi',
                                const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval:
                                (maxConsultations / 4).ceilToDouble(),
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: const Color(0xFFE5E9F0),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: bottomLabel,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval:
                                    (maxConsultations / 4).ceilToDouble(),
                                getTitlesWidget: (v, meta) {
                                  if (v == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4,
                                    child: Text('${v.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF7A93AA))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: consultationBars,
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.adminReports),
                  child: const Text(
                    'Lihat Detail Laporan',
                    style: TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
"""

    dash = dash.replace(chart_section, new_dash_chart_section)
    
    # Remove _chartPill method
    chart_pill_match = re.search(r'Widget _chartPill\(.*?\}\s*\}', dash, re.DOTALL)
    if chart_pill_match:
        dash = dash.replace(chart_pill_match.group(0), '')
        
    with open('lib/features/admin/admin_dashboard_screens.dart', 'w', encoding='utf-8') as f:
        f.write(dash)
        
    # Now build the Revenue Chart for report
    revenue_chart_section = """Widget _buildRevenueChartSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getAdminChartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];
        double maxRevenue = 1;
        double totalRevenue = 0;

        for (var row in data) {
          final r = (row['total_revenue'] as num?)?.toDouble() ?? 0;
          if (r > maxRevenue) maxRevenue = r;
          totalRevenue += r;
        }

        final revenueSpots = <FlSpot>[];
        for (int i = 0; i < data.length; i++) {
          final revenue = (data[i]['total_revenue'] as num?)?.toDouble() ?? 0;
          revenueSpots.add(FlSpot(i.toDouble(), revenue));
        }

        Widget bottomLabel(double value, TitleMeta meta) {
          final idx = value.toInt();
          if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
          final parts = (data[idx]['date'] as String).split('-');
          if (parts.length != 3) return const SizedBox.shrink();
          if (data.length > 8 &&
              idx != 0 &&
              idx != data.length - 1 &&
              idx % (data.length ~/ 4) != 0) {
            return const SizedBox.shrink();
          }
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 6,
            child: Text('${parts[2]}/${parts[1]}',
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF7A93AA))),
          );
        }

        Widget leftRevenueLabel(double value, TitleMeta meta) {
          if (value == 0) return const SizedBox.shrink();
          final label = value >= 1000000
              ? '${(value / 1000000).toStringAsFixed(1)}jt'
              : '${(value / 1000).toStringAsFixed(0)}k';
          return SideTitleWidget(
            axisSide: meta.axisSide,
            space: 4,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 9, color: Color(0xFF7A93AA))),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Grafik Pendapatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F2646),
                    ),
                  ),
                  if (totalRevenue > 0)
                    Text(
                      'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalRevenue)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF7A93AA)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 190,
                child: data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.show_chart,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            const Text(
                              'Belum ada data pada periode ini',
                              style: TextStyle(
                                  color: Color(0xFF7A93AA), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: maxRevenue * 1.25,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxRevenue / 4,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: const Color(0xFFE5E9F0),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: bottomLabel,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 44,
                                interval: maxRevenue / 4,
                                getTitlesWidget: leftRevenueLabel,
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) =>
                                  const Color(0xFF0F2646),
                              getTooltipItems: (spots) => spots
                                  .map((s) => LineTooltipItem(
                                        NumberFormat.currency(
                                                locale: 'id_ID',
                                                symbol: 'Rp ',
                                                decimalDigits: 0)
                                            .format(s.y),
                                        const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ))
                                  .toList(),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: revenueSpots,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: const Color(0xFF00C48C),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, idx) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                  strokeColor: const Color(0xFF00C48C),
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF00C48C)
                                        .withOpacity(0.25),
                                    const Color(0xFF00C48C)
                                        .withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }"""
    
    # Replace the placeholder in report
    placeholder = r'''              // GRAFIK PENDAPATAN
              const Text\('Grafik Pendapatan'.*?child: const Center\(\s*// Placeholder for chart\s*child: Icon\(Icons.show_chart,\s*size: 80, color: Color\(0xFF2196F3\)\),\s*\),\s*\),'''
    
    report = re.sub(placeholder, '_buildRevenueChartSection(),', report, flags=re.DOTALL)
    
    # Add imports to report if needed
    if "import 'package:fl_chart/fl_chart.dart';" not in report:
        report = report.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:fl_chart/fl_chart.dart';\nimport 'package:intl/intl.dart';")
        
    # Append the method to the AdminReportScreen class in report
    # We find the end of the class. It ends before `class AdminSettingsScreen`
    # Let's just insert it before the last closing brace of AdminReportScreen
    class_end = report.find('class AdminSettingsScreen')
    if class_end != -1:
        # Find the last closing brace before class_end
        brace_pos = report.rfind('}', 0, class_end - 1)
        # We need to insert the method inside the AdminReportScreen class.
        # But wait, AdminReportScreen ends with `Widget _buildStatCard(...) { ... } }`
        
        # It's safer to just regex replace the final `  }\n}\n\n// ==== MOCKUP 19` 
        # with `  }\n\n  ` + new_method + `\n}\n\n// ==== MOCKUP 19`
        
        # Or simpler, search for the end of AdminReportScreen by looking at _buildStatCard
        pattern = r'(Widget _buildStatCard.*?\}\s*\n)\}'
        match = re.search(pattern, report, flags=re.DOTALL)
        if match:
            report = report[:match.end(1)] + '\n' + revenue_chart_section + '\n}\n' + report[match.end():]
        else:
            print("Could not find the end of AdminReportScreen")

    with open('lib/features/admin/admin_system_screens.dart', 'w', encoding='utf-8') as f:
        f.write(report)
        
    print("Done")

process()
