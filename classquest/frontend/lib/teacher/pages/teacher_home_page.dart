import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = false;
  User? _currentUser;

  final List<String> _quickAddRules = ['主动回答+2', '优秀作业+3', '课堂专注+2', '小组合作+3'];
  final List<String> _quickSubtractRules = ['迟到-2', '未带作业-3', '上课走神-2', '干扰课堂-3'];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final authService = context.read<AuthService>();
    setState(() {
      _currentUser = authService.currentUser;
    });
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/users/students');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _students = data['students'] ?? [];
          _filteredStudents = List.from(_students);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载学生列表失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(_students);
      } else {
        _filteredStudents = _students
            .where((student) =>
                student['username'].toLowerCase().contains(query.toLowerCase()) ||
                student['real_name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addPoints(int userId, int points, String reason) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post('/points/add', body: {
        'user_id': userId,
        'points': points,
        'reason': reason,
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(points > 0 ? '✓ 积分添加成功' : '✓ 积分扣除成功'),
            backgroundColor: points > 0 ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _batchAddPoints(int points, String reason) async {
    try {
      final apiService = context.read<ApiService>();
      int successCount = 0;
      for (var student in _filteredStudents) {
        final response = await apiService.post('/points/add', body: {
          'user_id': student['id'],
          'points': points,
          'reason': reason,
        });
        if (response.statusCode == 200) {
          successCount++;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ 已为 $successCount 名学生${points > 0 ? "添加" : "扣除"}积分'),
          backgroundColor: points > 0 ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('批量操作失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: Text(
          _currentUser?.realName ?? '任课教师',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildQuickPointsTab(),
          _buildStudentsTab(),
          _buildRecordsTab(),
          _buildSettingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF16213e),
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '快速积分'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '学生'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }

  Widget _buildQuickPointsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 快速加分区域
          const Text(
            '快速加分',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _quickAddRules.length,
            itemBuilder: (context, index) {
              final rule = _quickAddRules[index];
              final points = int.parse(rule.substring(rule.length - 1));
              return ElevatedButton(
                onPressed: () => _showStudentSelectionDialog(points, rule),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(rule, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(height: 24),

          // 快速扣分区域
          const Text(
            '快速扣分',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _quickSubtractRules.length,
            itemBuilder: (context, index) {
              final rule = _quickSubtractRules[index];
              final points = -int.parse(rule.substring(rule.length - 1));
              return ElevatedButton(
                onPressed: () => _showStudentSelectionDialog(points, rule),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(rule, style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
          const SizedBox(height: 24),

          // 全班操作区域
          const Text(
            '全班操作',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBatchDialog(1, '全班奖励'),
                  icon: const Icon(Icons.add),
                  label: const Text('全班+1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBatchDialog(-1, '全班惩罚'),
                  icon: const Icon(Icons.remove),
                  label: const Text('全班-1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索学生姓名或学号...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF16213e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: _filterStudents,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredStudents[index];
                    return Card(
                      color: const Color(0xFF1e1e2e),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            student['real_name'][0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          student['real_name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '学号: ${student['username']} | 积分: ${student['total_points'] ?? 0}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () => _showQuickAddDialog(student['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.orange),
                              onPressed: () => _showQuickSubtractDialog(student['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRecordsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '最近操作记录',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildRecordItem(
          icon: Icons.add_circle,
          color: Colors.green,
          title: '张三 - 主动回答',
          points: '+2',
          time: '10分钟前',
        ),
        _buildRecordItem(
          icon: Icons.remove_circle,
          color: Colors.orange,
          title: '李四 - 迟到',
          points: '-2',
          time: '15分钟前',
        ),
        _buildRecordItem(
          icon: Icons.add_circle,
          color: Colors.green,
          title: '王五 - 优秀作业',
          points: '+3',
          time: '20分钟前',
        ),
        _buildRecordItem(
          icon: Icons.add_circle,
          color: Colors.green,
          title: '赵六 - 小组合作',
          points: '+3',
          time: '25分钟前',
        ),
      ],
    );
  }

  Widget _buildRecordItem({
    required IconData icon,
    required Color color,
    required String title,
    required String points,
    required String time,
  }) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(time, style: const TextStyle(color: Colors.white54)),
        trailing: Text(
          points,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('个人信息', style: TextStyle(color: Colors.white)),
            subtitle: Text(_currentUser?.realName ?? '', style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
        ),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.white),
            title: const Text('科目信息', style: TextStyle(color: Colors.white)),
            subtitle: Text('科目ID: ${_currentUser?.subjectId ?? 1}', style: const TextStyle(color: Colors.white54)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
        ),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white),
            title: const Text('通知设置', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {},
          ),
        ),
        Card(
          color: const Color(0xFF1e1e2e),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('退出登录', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.read<AuthService>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('搜索学生', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '输入姓名或学号...',
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF16213e),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          onChanged: (value) {
            _filterStudents(value);
            setState(() => _selectedIndex = 1);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(int userId) {
    int points = 1;
    String reason = '课堂表现';
    final reasons = ['主动回答', '优秀作业', '课堂专注', '小组合作', '其他'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e2e),
          title: const Text('添加积分', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () => setDialogState(() => points > 1 ? points-- : null),
                  ),
                  Text(
                    '$points',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => setDialogState(() => points++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('原因:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map((r) {
                  return ChoiceChip(
                    label: Text(r, style: const TextStyle(color: Colors.white)),
                    selected: reason == r,
                    onSelected: (selected) {
                      setDialogState(() => reason = selected ? r : reason);
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: const Color(0xFF16213e),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                _addPoints(userId, points, reason);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSubtractDialog(int userId) {
    int points = 1;
    String reason = '课堂纪律';
    final reasons = ['迟到', '未带作业', '上课走神', '干扰课堂', '其他'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e2e),
          title: const Text('扣除积分', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () => setDialogState(() => points > 1 ? points-- : null),
                  ),
                  Text(
                    '$points',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => setDialogState(() => points++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('原因:', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map((r) {
                  return ChoiceChip(
                    label: Text(r, style: const TextStyle(color: Colors.white)),
                    selected: reason == r,
                    onSelected: (selected) {
                      setDialogState(() => reason = selected ? r : reason);
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: const Color(0xFF16213e),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                _addPoints(userId, -points, reason);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('确认'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentSelectionDialog(int points, String rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text('选择学生 - $rule', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              return ListTile(
                title: Text(
                  student['real_name'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '学号: ${student['username']}',
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  _addPoints(student['id'], points, rule);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBatchDialog(int points, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text('$reason', style: const TextStyle(color: Colors.white)),
        content: Text(
          '确认要为全班 ${_filteredStudents.length} 名学生${points > 0 ? "添加" : "扣除"} ${points.abs()} 积分吗？',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              _batchAddPoints(points, reason);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: points > 0 ? Colors.green : Colors.orange,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
