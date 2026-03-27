import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';
import '../../shared/widgets/charts.dart';

class GroupCompetitionPage extends StatefulWidget {
  const GroupCompetitionPage({super.key});

  @override
  State<GroupCompetitionPage> createState() => _GroupCompetitionPageState();
}

class _GroupCompetitionPageState extends State<GroupCompetitionPage> {
  List<Map<String, dynamic>> _groups = [];
  Map<String, dynamic>? _myGroup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/groups');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _groups = List<Map<String, dynamic>>.from(data['groups'] ?? []);
          _myGroup = data['my_group'];
        });
      }
    } catch (e) {
      print('加载小组数据失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showGroupDetails(Map<String, dynamic> group) {
    showDialog(
      context: context,
      builder: (context) => _GroupDetailDialog(
        group: group,
        isMyGroup: _myGroup != null && _myGroup!['id'] == group['id'],
        onRefresh: _loadGroups,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '小组竞赛',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadGroups,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 我的小组卡片
                  if (_myGroup != null) ...[
                    _buildMyGroupCard(),
                    const SizedBox(height: 24),
                  ],
                  // 排行榜
                  const Text(
                    '小组积分榜',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GroupComparisonChart(groupData: _groups),
                  const SizedBox(height: 24),
                  // 小组列表
                  const Text(
                    '全部小组',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_groups.length, (index) {
                    final group = _groups[index];
                    return _buildGroupCard(group, index + 1);
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildMyGroupCard() {
    if (_myGroup == null) return const SizedBox();

    final group = _myGroup!;
    final rank = _groups.indexWhere((g) => g['id'] == group['id']) + 1;

    return Card(
      color: const Color(0xFF1e1e2e),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '我的小组',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (rank <= 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: [
                        Colors.amber,
                        Colors.orange,
                        Colors.brown,
                      ][rank - 1].withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: [
                          Colors.amber,
                          Colors.orange,
                          Colors.brown,
                        ][rank - 1],
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: [
                            Colors.amber,
                            Colors.orange,
                            Colors.brown,
                          ][rank - 1],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '第$rank名',
                          style: TextStyle(
                            color: [
                              Colors.amber,
                              Colors.orange,
                              Colors.brown,
                            ][rank - 1],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              group['name'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${group['member_count']}名成员',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    label: '总积分',
                    value: '${group['total_points']}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.person,
                    label: '平均分',
                    value: '${(group['total_points'] / group['member_count']).toInt()}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(Map<String, dynamic> group, int rank) {
    final isTopThree = rank <= 3;
    final isMyGroup = _myGroup != null && _myGroup!['id'] == group['id'];

    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGroupDetails(group),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isMyGroup
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : null,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 排名
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isTopThree
                      ? [
                          Colors.amber,
                          Colors.orange,
                          Colors.brown,
                        ][rank - 1]
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: isTopThree
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isTopThree ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 小组信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isMyGroup
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                        ),
                        if (isMyGroup) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '我的小组',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group['member_count']}名成员',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // 积分
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${group['total_points']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '平均 ${(group['total_points'] / group['member_count']).toInt()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupDetailDialog extends StatelessWidget {
  final Map<String, dynamic> group;
  final bool isMyGroup;
  final VoidCallback onRefresh;

  const _GroupDetailDialog({
    required this.group,
    required this.isMyGroup,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final members = group['members'] as List<dynamic>? ?? [];

    return Dialog(
      backgroundColor: const Color(0xFF1e1e2e),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
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
                    child: Text(
                      group['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 内容
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 统计信息
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          label: '总积分',
                          value: '${group['total_points']}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.person,
                          label: '成员数',
                          value: '${members.length}',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 成员列表
                  const Text(
                    '小组成员',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(members.length, (index) {
                    final member = members[index];
                    return Card(
                      color: const Color(0xFF16213e),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            (member['name'] as String)[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          '${member['points']}分',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // 底部按钮
            if (isMyGroup)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('管理成员'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
