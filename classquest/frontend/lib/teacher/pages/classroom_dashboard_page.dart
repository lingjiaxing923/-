import 'package:flutter/material.dart';
import '../../shared/widgets/charts.dart';

class ClassroomDashboardPage extends StatefulWidget {
  const ClassroomDashboardPage({super.key});

  @override
  State<ClassroomDashboardPage> createState() => _ClassroomDashboardPageState();
}

class _ClassroomDashboardPageState extends State<ClassroomDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 16),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '课堂积分看板',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.group, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '三年二班',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal:12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.school, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '数学课',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  _getCurrentTime(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildOverviewTab(),
          _buildLeaderboardTab(),
          _buildGroupsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 统计卡片
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: Icons.people,
                    label: '班级人数',
                    value: '45',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    icon: Icons.star,
                    label: '总积分',
                    value: '12,580',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    icon: Icons.trending_up,
                    label: '今日加分',
                    value: '+156',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    icon: Icons.trending_down,
                    label: '今日扣分',
                    value: '-23',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 实时动态
            PointsLiveWidget(
              recentPoints: [
                {'name': '张三', 'reason': '主动回答问题', 'points': 2, 'time': '刚刚'},
                {'name': '李四', 'reason': '迟到', 'points': -2, 'time': '1分钟前'},
                {'name': '王五', 'reason': '优秀作业', 'points': 3, 'time': '2分钟前'},
                {'name': '赵六', 'reason': '小组合作', 'points': 3, 'time': '3分钟前'},
                {'name': '孙七', 'reason': '课堂专注', 'points': 2, 'time': '4分钟前'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final topStudents = [
      {'rank': 1, 'name': '张三', 'points': 1234, 'change': '+12', 'trend': true},
      {'rank': 2, 'name': '李四', 'points': 1189, 'change': '+8', 'trend': true},
      {'rank': 3, 'name': '王五', 'points': 1156, 'change': '-3', 'trend': false},
      {'rank': 4, 'name': '赵六', 'points': 1098, 'change': '+5', 'trend': true},
      {'rank': 5, 'name': '孙七', 'points': 1056, 'change': '+2', 'trend': true},
      {'rank': 6, 'name': '周八', 'points': 1023, 'change': '-1', 'trend': false},
      {'rank': 7, 'name': '吴九', 'points': 989, 'change': '+15', 'trend': true},
      {'rank': 8, 'name': '郑十', 'points': 956, 'change': '+6', 'trend': true},
      {'rank': 9, 'name': '钱十一', 'points': 923, 'change': '-2', 'trend': false},
      {'rank': 10, 'name': '孙十二', 'points': 889, 'change': '+9', 'trend': true},
    ];

    return Column(
      children: [
        // 前三名特别展示
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPodiumStudent(topStudents[1], 2),
              _buildPodiumStudent(topStudents[0], 1),
              _buildPodiumStudent(topStudents[2], 3),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 排行榜列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topStudents.length,
            itemBuilder: (context, index) {
              final student = topStudents[index];
              return _buildLeaderboardItem(student);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumStudent(Map<String, dynamic> student, int rank) {
    final heights = [160, 180, 140];
    final colors = [Colors.orange, Colors.amber, Colors.brown];

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors[rank - 1],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Text(
              student['name'][0],
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: heights[rank - 1],
          decoration: BoxDecoration(
            color: colors[rank - 1].withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${student['points']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          student['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: student['trend'] ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            student['change'],
            style: TextStyle(
              color: student['trend'] ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> student) {
    final rank = student['rank'] as int;
    final isTopThree = rank <= 3;

    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isTopThree
                    ? [Colors.amber, Colors.orange, Colors.brown][rank - 1]
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isTopThree ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        student['trend'] ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: student['trend'] ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        student['change'],
                        style: TextStyle(
                          fontSize: 12,
                          color: student['trend'] ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${student['points']}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isTopThree ? Colors.amber : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    final groupData = [
      {'name': '火箭组', 'points': 1856, 'members': 6},
      {'name': '飞鹰组', 'points': 1723, 'members': 5},
      {'name': '雄狮组', 'points': 1654, 'members': 6},
      {'name': '猛虎组', 'points': 1589, 'members': 5},
      {'name': '蛟龙组', 'points': 1523, 'members': 6},
      {'name': '凤凰组', 'points': 1456, 'members': 5},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GroupComparisonChart(groupData: groupData),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: groupData.length,
              itemBuilder: (context, index) {
                final group = groupData[index];
                return Card(
                  color: const Color(0xFF1e1e2e),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      group['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${group['members']}名成员',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${group['points']}分',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.dashboard,
            label: '总览',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.emoji_events,
            label: '排行榜',
            index: 1,
          ),
          _buildNavItem(
            icon: Icons.group_work,
            label: '小组',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
