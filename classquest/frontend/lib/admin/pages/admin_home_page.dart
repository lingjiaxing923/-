import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/auth_service.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  int _totalStudents = 45;
  int _totalPoints = 56800;
  int _activeExchanges = 3;
  int _pendingAppeals = 2;

  void _logout() async {
    await context.read<AuthService>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('班主任工作台'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            color: Colors.white,
            tooltip: '退出登录',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildStudentsTab(),
          _buildPointsTab(),
          _buildRewardsTab(),
          _buildAppealsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1a1a2e),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '工作台'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '学生'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '积分'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: '商城'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: '申诉'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 统计卡片
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.people,
                  '学生总数',
                  _totalStudents.toString(),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.star,
                  '总积分',
                  _totalPoints.toString(),
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.card_giftcard,
                  '待审核兑换',
                  _activeExchanges.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.report,
                  '待处理申诉',
                  _pendingAppeals.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 快速操作卡片
          Text(
            '快速操作',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 快速加分
          _buildQuickActionCard('加分', [
            _buildQuickActionButton(Icons.check_circle, '主动回答', '+2', Colors.green),
            _buildQuickActionButton(Icons.edit_note, '优秀作业', '+3', Colors.blue),
            _buildQuickActionButton(Icons.group_work, '小组协作', '+2', Colors.orange),
            _buildQuickActionButton(Icons.star, '课堂表现', '+1', Colors.purple),
          ]),
          
          const SizedBox(height: 16),
          
          // 快速扣分
          _buildQuickActionCard('扣分', [
            _buildQuickActionButton(Icons.warning, '迟到', '-2', Colors.red),
            _buildQuickActionButton(Icons.do_not_disturb, '违纪', '-5', Colors.red),
            _buildQuickActionButton(Icons.assignment_late, '未交作业', '-3', Colors.red),
          ]),
          
          const SizedBox(height: 24),
          
          // 最近动态
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Card(
      color: const Color(0xFF1e1e2e),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, List<Widget> buttons) {
    return Card(
      color: const Color(0xFF1e1e2e),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, String points, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _showPointsDialog(label, int.parse(points.replaceAll('+', '').replaceAll('-', '')), color),
      icon: icon,
      label: '$label $points',
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: Size(100, 50),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      color: const Color(0xFF1e1e2e),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('最近动态', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                TextButton(
                  onPressed: () {},
                  child: const Text('查看全部', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem('张三', '主动回答', '+2', '10:30', Colors.green),
            const SizedBox(height: 8),
            _buildActivityItem('李四', '优秀作业', '+3', '09:45', Colors.blue),
            const SizedBox(height: 8),
            _buildActivityItem('王五', '迟到', '-2', '今天', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String name, String action, String points, String time, Color color) {
    return Row(
      children: [
        Text(name, style: const TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(child: Text(action, style: const TextStyle(fontSize: 14, color: Colors.white70))),
        const SizedBox(width: 8),
        Text(points, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 8),
        Text(time, style: const TextStyle(fontSize: 14, color: Colors.white54)),
      ],
    );
  }

  void _showPointsDialog(String action, int points, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text('$action积分', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('操作: $action $points', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: '选择学生',
                hintText: '输入学生姓名搜索',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '备注 (可选)',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$action积分操作成功'),
                  backgroundColor: color,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索学生',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF1e1e2e),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: '添加学生',
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload),
                label: '批量导入',
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 45,
            itemBuilder: (context, index) {
              return _buildStudentCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(int index) {
    final points = (index + 1) * 120;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1e1e2e),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        title: Text('学生 ${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('小组 ${((index % 3) + 1)}班', style: const TextStyle(color: Colors.white70)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$points 分', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('#${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildPointsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActionCard('加分', [
          _buildQuickActionButton(Icons.check_circle, '主动回答', '+2', Colors.green),
          _buildQuickActionButton(Icons.edit_note, '优秀作业', '+3', Colors.blue),
          _buildQuickActionButton(Icons.group_work, '小组协作', '+2', Colors.orange),
          _buildQuickActionButton(Icons.star, '课堂表现', '+1', Colors.purple),
        ]),
        const SizedBox(height: 16),
        _buildQuickActionCard('扣分', [
          _buildQuickActionButton(Icons.warning, '迟到', '-2', Colors.red),
          _buildQuickActionButton(Icons.do_not_disturb, '违纪', '-5', Colors.red),
          _buildQuickActionButton(Icons.assignment_late, '未交作业', '-3', Colors.red),
        ]),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF1e1e2e),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('积分规则管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRuleItem('主动回答', '+2', '每人每天限3次'),
                _buildRuleItem('优秀作业', '+3', '每人每天限1次'),
                _buildRuleItem('迟到', '-2', '不限次数'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String name, String points, String limit) {
    return Card(
      color: const Color(0xFF252525),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(limit, style: const TextStyle(color: Colors.white70)),
        trailing: Text(points, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
      ),
    );
  }

  Widget _buildRewardsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索商品',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF1e1e2e),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: '添加商品',
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildRewardCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard(int index) {
    final rewards = [
      {'name': '免作业卡', 'points': 100, 'type': 'privilege', 'stock': -1},
      {'name': '座位优先权', 'points': 200, 'type': 'privilege', 'stock': 5},
      {'name': '表扬电话', 'points': 50, 'type': 'privilege', 'stock': -1},
      {'name': '奶茶券', 'points': 300, 'type': 'physical', 'stock': 10},
      {'name': '笔记本', 'points': 150, 'type': 'physical', 'stock': 20},
      {'name': '徽章', 'points': 50, 'type': 'virtual', 'stock': 50},
    ];
    
    final reward = rewards[index % rewards.length];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1e1e2e),
      child: ListTile(
        leading: Icon(
          reward['type'] == 'privilege' ? Icons.workspace_premium : Icons.card_giftcard,
          color: Colors.orange,
          size: 40,
        ),
        title: Text(reward['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${reward['type'] == 'privilege' ? '特权' : '实物'}商品', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('${reward['points']} 积分', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            if (reward['stock'] >= 0)
              Text('库存: ${reward['stock']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () {},
      ),
    );
  }

  Widget _buildAppealsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton(
            options: const ['待处理', '已处理'],
            onSelectionChanged: (index) {},
            selectedColor: Theme.of(context).primaryColor,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildAppealCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppealCard(int index) {
    final appeals = [
      {'name': '张三', 'reason': '迟到扣分错误', 'status': 'pending'},
      {'name': '李四', 'reason': '作业未记录', 'status': 'pending'},
      {'name': '王五', 'reason': '迟到记录错误', 'status': 'pending'},
      {'name': '赵六', 'reason': '分数计算错误', 'status': 'processed'},
      {'name': '钱七', 'reason': '作业漏加', 'status': 'processed'},
    ];
    
    final appeal = appeals[index % appeals.length];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1e1e2e),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
          backgroundColor: appeal['status'] == 'processed' ? Colors.grey : Colors.orange,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appeal['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(appeal['reason'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        trailing: appeal['status'] == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check),
                    label: '通过',
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close),
                    label: '驳回',
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              )
            : Text('已处理', style: const TextStyle(color: Colors.white70)),
        onTap: () {},
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.blue, size: 30),
            title: const Text('个人信息', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.class_, color: Colors.green, size: 30),
            title: const Text('班级管理', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.settings, color: Colors.orange, size: 30),
            title: const Text('系统设置', style: TextStyle(color: Colors.white, fontSize: 16)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.info, color: Colors.purple, size: 30),
            title: const Text('关于', style: TextStyle(color: Colors.white, fontSize: 16)),
            subtitle: const Text('ClassQuest v1.0.0', style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: '退出登录',
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
