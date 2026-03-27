import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/auth_service.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({Key? key}) : super(key: key);

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  int _currentIndex = 0;
  String _subjectName = '语文';
  final List<Map<String, dynamic>> _students = List.generate(10, (index) => {
    'id': index + 1,
    'name': '学生 ${index + 1}',
    'points': (index + 1) * 100,
    'group': '小组 ${((index % 3) + 1)}',
  });

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
        title: Text('$_subjectName 科代表工作台', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPointsTab(),
          _buildStudentsTab(),
          _buildRecordsTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '积分'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '学生'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildPointsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: const Color(0xFF1e1e2e),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '快速加分',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAction(Icons.check_circle, '主动回答', '+2', Colors.green),
                      _buildQuickAction(Icons.edit_note, '优秀作业', '+3', Colors.blue),
                      _buildQuickAction(Icons.group_work, '小组协作', '+2', Colors.orange),
                      _buildQuickAction(Icons.star, '课堂表现', '+1', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: const Color(0xFF1e1e2e),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '快速扣分',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickAction(Icons.warning, '迟到', '-2', Colors.red),
                      _buildQuickAction(Icons.do_not_disturb, '违纪', '-5', Colors.red),
                      _buildQuickAction(Icons.assignment_late, '未交作业', '-3', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String points, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _showPointsDialog(label, int.parse(points.replaceAll('+', '').replaceAll('-', '')), color),
      icon: icon,
      label: '$label $points',
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size(80, 40),
      ),
    );
  }

  void _showPointsDialog(String label, int points, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text('$label积分', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label $points', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '选择学生',
                hintText: '搜索学生姓名',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 12),
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
                  content: Text('$label积分操作成功'),
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
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索学生',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFF1e1e2e),
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              return _buildStudentCard(_students[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1e1e2e),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${student['id']}'),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        title: Text(student['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(student['group'], style: const TextStyle(color: Colors.white70)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${student['points']} 分', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            Text('#${student['points'] ~/ 100 + 1}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildRecordsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(5, (index) => _buildRecordItem(index)),
    ),
    );
  }

  Widget _buildRecordItem(int index) {
    final records = [
      {'action': '主动回答', 'student': '张三', 'points': '+2', 'time': '今天 10:30'},
      {'action': '优秀作业', 'student': '李四', 'points': '+3', 'time': '昨天'},
      {'action': '迟到', 'student': '王五', 'points': '-2', 'time': '3天前'},
      {'action': '课堂表现', 'student': '赵六', 'points': '+1', 'time': '5天前'},
      {'action': '违纪', 'student': '钱七', 'points': '-5', 'time': '1周前'},
    ];
    
    final record = records[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF1e1e2e),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('${index + 1}'),
          backgroundColor: record['points'].startsWith('+') ? Colors.green : Colors.red,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(record['student'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(record['action'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(record['points'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: record['points'].startsWith('+') ? Colors.green : Colors.red)),
            Text(record['time'], style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
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
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('个人资料', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.green),
            title: const Text('科目信息', style: TextStyle(color: Colors.white)),
            subtitle: Text(_subjectName, style: TextStyle(color: Colors.white70)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('通知设置', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: '退出登录',
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
      ],
    );
  }
}
