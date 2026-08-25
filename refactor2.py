import re

def process():
    with open('lib/features/admin/admin_dashboard_screens.dart', 'r', encoding='utf-8') as f:
        dash = f.read()

    # 1. Remove _chartTabIndex from dashboard
    dash = re.sub(r'\s*int _chartTabIndex = 1;.*?(\n|$)', '\n', dash)

    # Instead of regexing _buildAdaptiveChartSection, let's find the start and end precisely.
    start_str = "Widget _buildAdaptiveChartSection() {"
    start_idx = dash.find(start_str)
    if start_idx == -1:
        print("Could not find start")
        return
        
    # We need to find the matching closing brace for _buildAdaptiveChartSection()
    depth = 0
    end_idx = -1
    for i in range(start_idx + len(start_str) - 1, len(dash)):
        if dash[i] == '{':
            depth += 1
        elif dash[i] == '}':
            depth -= 1
            if depth == 0:
                end_idx = i
                break
                
    if end_idx == -1:
        print("Could not find end of _buildAdaptiveChartSection")
        return
        
    old_section = dash[start_idx:end_idx + 1]
    
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
  }"""

    dash = dash.replace(old_section, new_dash_chart_section)
    
    # Remove _chartPill method similarly
    pill_start_str = "Widget _chartPill(String title, int index, Color activeColor) {"
    pill_start_idx = dash.find(pill_start_str)
    if pill_start_idx != -1:
        depth = 0
        pill_end_idx = -1
        for i in range(pill_start_idx + len(pill_start_str) - 1, len(dash)):
            if dash[i] == '{':
                depth += 1
            elif dash[i] == '}':
                depth -= 1
                if depth == 0:
                    pill_end_idx = i
                    break
        if pill_end_idx != -1:
            old_pill = dash[pill_start_idx:pill_end_idx + 1]
            dash = dash.replace(old_pill, "")
            
    with open('lib/features/admin/admin_dashboard_screens.dart', 'w', encoding='utf-8') as f:
        f.write(dash)
        
    print("Dashboard processed.")

process()
