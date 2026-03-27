import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';

class Alert {
  final String type;
  final String severity;
  final int? userId;
  final String? userName;
  final String? username;
  final String message;
  final String timestamp;
  final List<String> suggestions;
  final Map<String, dynamic>? details;

  Alert({
    required this.type,
    required this.severity,
    this.userId,
    this.userName,
    this.username,
    required this.message,
    required this.timestamp,
    required this.suggestions,
    this.details,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      type: json['type'] as String,
      severity: json['severity'] as String,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      username: json['username'] as String?,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      suggestions: List<String>.from(json['suggestions'] ?? []),
      details: json,
    );
  }
}

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  String _selectedType = 'all';
  int _selectedDays = 7;
  bool _isLoading = false;
  List<Alert> _alerts = [];
  Map<String, dynamic>? _statistics;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _loadStatistics();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(
        '/alerts/warnings?class_id=1&warning_type=$_selectedType&days=$_selectedDays',
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _alerts = (data['warnings'] as List)
              .map((w) => Alert.fromJson(w as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('加载预警失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(
        '/alerts/statistics?class_id=1&days=$_selectedDays',
      );
      if (response.statusCode == 200) {
        setState(() {
          _statistics = Map<String, dynamic>.from(response.data);
        });
      }
    } catch (e) {
      print('加载统计数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '预警系统',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadAlerts();
              _loadStatistics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          if (_statistics != null) _buildStatistics(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _alerts.isEmpty
                    ? _buildEmptyState()
                    : _buildAlertsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 类型筛选
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', 'all'),
                _buildFilterChip('低积分', 'low_points'),
                _buildFilterChip('连续零分', 'zero_points'),
                _buildFilterChip('积分下滑', 'declining'),
                _buildFilterChip('待处理申诉', 'appeals'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 天数筛选
          Row(
            children: [
              const Text(
                '时间范围:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 12),
              _buildDaysChip('3天', 3),
              _buildDaysChip('7天', 7),
              _buildDaysChip('14天', 14),
              _buildDaysChip('30天', 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedType = value);
            _loadAlerts();
          }
        },
        selectedColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.white10,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildDaysChip(String label, int value) {
    final isSelected = _selectedDays == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedDays = value);
            _loadAlerts();
            _loadStatistics();
          }
        },
        selectedColor: Colors.blue,
        backgroundColor: Colors.white10,
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = _statistics!;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.warning,
              label: '低积分',
              value: '${stats['low_points_count']}',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.block,
              label: '连续零分',
              value: '${stats['zero_points_count']}',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.report,
              label: '待处理申诉',
              value: '${stats['pending_appeals_count']}',
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFF1e1e2e),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无预警信息',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '班级运行良好',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return _buildAlertCard(alert, index);
      },
    );
  }

  Widget _buildAlertCard(Alert alert, int index) {
    final severityColors = {
      'high': Colors.red,
      'medium': Colors.orange,
      'low': Colors.yellow,
    };

    final typeLabels = {
      'low_points': '低积分预警',
      'zero_points': '连续零分预警',
      'declining': '积分下滑预警',
      'appeals': '申诉预警',
    };

    final typeIcons = {
      'low_points': Icons.trending_down,
      'zero_points': Icons.block,
      'declining': Icons.arrow_downward,
      'appeals': Icons.report,
    };

    final severity = alert.severity;
    final color = severityColors[severity] ?? Colors.grey;

    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            typeIcons[alert.type] ?? Icons.warning,
            color: color,
            size: 24,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    typeLabels[alert.type] ?? alert.type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              alert.message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        subtitle: Text(
          _formatTimestamp(alert.timestamp),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 建议操作
                const Text(
                  '建议操作:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(alert.suggestions.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ',
                          style: const TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            alert.suggestions[index],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // 操作按钮
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // 查看学生详情
                        },
                        icon: const Icon(Icons.person, size: 18),
                        label: const Text('查看学生'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 标记为已处理
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('已处理'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return '${dt.month}/${dt.day}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('预警设置', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem('低积分阈值', '100'),
            _buildSettingItem('连续零分天数', '5'),
            _buildSettingItem('积分下滑比例', '20%'),
            _buildSettingItem('预警通知', '开启'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('设置已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }
}
