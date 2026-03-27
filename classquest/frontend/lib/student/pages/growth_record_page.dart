import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthRecordPage extends StatefulWidget {
  const GrowthRecordPage({Key? key}) : super(key: key);

  @override
  State<GrowthRecordPage> createState() => _GrowthRecordPageState();
}

class _GrowthRecordPageState extends State<GrowthRecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长记录'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 积分趋势图
            Card(
              color: const Color(0xFF1e1e2e),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '积分增长趋势',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() % 2 == 0) {
                                    return Text('${value.toInt() * 200}分',
                                        style: const TextStyle(color: Colors.white70, fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final months = ['1月', '2月', '3月', '4月', '5月', '6月'];
                                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                                    return Text(months[value.toInt()], style: const TextStyle(color: Colors.white70, fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.white10.withOpacity(0.1)),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 100),
                                FlSpot(1, 280),
                                FlSpot(2, 350),
                                FlSpot(3, 320),
                                FlSpot(4, 380),
                                FlSpot(5, 450),
                              ],
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 积分时间轴
            Card(
              color: const Color(0xFF1e1e2e),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '积分明细',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildTimelineItem(Icons.add_circle, '主动回答', '+2', '今天 10:30', Colors.green),
                    const Divider(color: Colors.white12),
                    _buildTimelineItem(Icons.check_circle, '优秀作业', '+3', '3月26日', Colors.blue),
                    const Divider(color: Colors.white12),
                    _buildTimelineItem(Icons.group_work, '小组协作', '+2', '3月24日', Colors.orange),
                    const Divider(color: Colors.white12),
                    _buildTimelineItem(Icons.star, '课堂表现', '+1', '3月23日', Colors.purple),
                    const Divider(color: Colors.white12),
                    _buildTimelineItem(Icons.warning, '迟到', '-2', '3月22日', Colors.red),
                    const Divider(color: Colors.white12),
                    _buildTimelineItem(Icons.emoji_events, '进步奖励', '+20', '3月21日', Colors.amber),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(IconData icon, String action, String points, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(' · $time', style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
