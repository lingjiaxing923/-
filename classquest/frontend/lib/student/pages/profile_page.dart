import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user.dart';
import '../../shared/widgets/charts.dart';
import 'mentorship_page.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  User? _currentUser;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = context.read<AuthService>();
    setState(() {
      _currentUser = authService.currentUser;
    });
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/points/stats');
      if (response.statusCode == 200) {
        setState(() {
          _stats = Map<String, dynamic>.from(response.data);
        });
      }
    } catch (e) {
      print('加载统计数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = _stats?['total_points'] ?? 0;
    final usedPoints = _stats?['used_points'] ?? 0;
    final pendingPoints = _stats?['pending_points'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _currentUser?.realName?.substring(0, 1) ?? 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.realName ?? '学生',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '学号: ${_currentUser?.username ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 积分概览
                  const Text(
                    '积分概览',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          icon: Icons.star,
                          label: '总积分',
                          value: '$totalPoints',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.trending_up,
                          label: '本周排名',
                          value: '#8',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          icon: Icons.emoji_events,
                          label: '班级排名',
                          value: '#12',
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.group,
                          label: '小组排名',
                          value: '#3',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 积分使用环形图
                  PointsDonutChart(
                    totalPoints: totalPoints,
                    usedPoints: usedPoints,
                    pendingPoints: pendingPoints,
                  ),
                  const SizedBox(height: 24),
                  // 个人信息
                  const Text(
                    '个人信息',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.person,
                    label: '姓名',
                    value: _currentUser?.realName ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.badge,
                    label: '学号',
                    value: _currentUser?.username ?? '',
                  ),
                  _buildInfoCard(
                    icon: Icons.class_,
                    label: '班级',
                    value: '三年二班',
                  ),
                  _buildInfoCard(
                    icon: Icons.group_work,
                    label: '小组',
                    value: '火箭组',
                  ),
                  const SizedBox(height: 24),
                  // 师徒关系
                  const Text(
                    '师徒关系',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMentorshipCard(),
                  const SizedBox(height: 24),
                  // 成就徽章
                  const Text(
                    '成就徽章',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBadgesSection(),
                  const SizedBox(height: 24),
                  // 功能菜单
                  const Text(
                    '更多功能',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItems(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMentorshipCard() {
    return Card(
      color: const Color(0xFF1e1e2e),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MentorshipPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.group, color: Theme.of(context).primaryColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '暂无师徒关系',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击查看或申请师徒结对',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'icon': Icons.star, 'name': '积分达人', 'color': Colors.amber, 'unlocked': true},
      {'icon': Icons.trending_up, 'name': '进步之星', 'color': Colors.green, 'unlocked': true},
      {'icon': Icons.group_work, 'name': '团队合作', 'color': Colors.blue, 'unlocked': true},
      {'icon': Icons.workspace_premium, 'name': '全能选手', 'color': Colors.purple, 'unlocked': false},
      {'icon': Icons.emoji_events, 'name': '学习冠军', 'color': Colors.orange, 'unlocked': false},
      {'icon': Icons.local_fire_department, 'name': '连胜王者', 'color': Colors.red, 'unlocked': false},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.map((badge) {
        final isUnlocked = badge['unlocked'] as bool;
        return Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked
                ? (badge['color'] as Color).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked
                  ? (badge['color'] as Color)
                  : Colors.grey,
              width: isUnlocked ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                badge['icon'] as IconData,
                color: isUnlocked
                    ? badge['color'] as Color
                    : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                badge['name'] as String,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {'icon': Icons.notifications, 'label': '通知设置'},
      {'icon': Icons.security, 'label': '隐私设置'},
      {'icon': Icons.help, 'label': '帮助与反馈'},
      {'icon': Icons.info, 'label': '关于我们'},
      {'icon': Icons.logout, 'label': '退出登录', 'color': Colors.red},
    ];

    return Column(
      children: menuItems.map((item) {
        final color = item['color'] as Color?;
        final isLogout = item['label'] == '退出登录';

        return Card(
          color: const Color(0xFF1e1e2e),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: color ?? Theme.of(context).primaryColor,
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                color: color ?? Colors.white,
                fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              if (isLogout) {
                _showLogoutDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['label']}功能开发中')),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('退出登录', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要退出登录吗？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
