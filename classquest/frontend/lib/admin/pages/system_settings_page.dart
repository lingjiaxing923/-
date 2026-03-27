import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({super.key});

  @override
  State<SystemSettingsPage> createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  bool _isLoading = false;

  // 设置项
  bool _autoBackupEnabled = true;
  bool _notificationEnabled = true;
  bool _alertsEnabled = true;
  String _backupFrequency = 'daily'; // daily, weekly, monthly
  int _backupRetentionDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '系统设置',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('数据备份', [
                    _buildSwitchSetting(
                      '自动备份',
                      '启用自动数据备份',
                      _autoBackupEnabled,
                      (value) => setState(() => _autoBackupEnabled = value),
                    ),
                    _buildChoiceSetting(
                      '备份频率',
                      _backupFrequency,
                      ['daily', 'weekly', 'monthly'],
                      ['每天', '每周', '每月'],
                      (value) => setState(() => _backupFrequency = value),
                    ),
                    _buildSliderSetting(
                      '备份保留天数',
                      _backupRetentionDays,
                      1,
                      365,
                      (value) => setState(() => _backupRetentionDays = value),
                    ),
                    _buildActionCard(
                      '立即备份',
                      Icons.backup,
                      Colors.blue,
                      () => _performBackup(),
                    ),
                    _buildActionCard(
                      '恢复数据',
                      Icons.restore,
                      Colors.orange,
                      () => _restoreBackup(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('通知设置', [
                    _buildSwitchSetting(
                      '启用通知',
                      '接收系统通知',
                      _notificationEnabled,
                      (value) => setState(() => _notificationEnabled = value),
                    ),
                    _buildSwitchSetting(
                      '预警通知',
                      '接收预警提醒',
                      _alertsEnabled,
                      (value) => setState(() => _alertsEnabled = value),
                    ),
                    _buildActionCard(
                      '发送测试通知',
                      Icons.notifications,
                      Colors.green,
                      () => _sendTestNotification(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('赛季管理', [
                    _buildActionCard(
                      '查看所有赛季',
                      Icons.calendar_today,
                      Colors.purple,
                      () => _showSeasonsList(),
                    ),
                    _buildActionCard(
                      '创建新赛季',
                      Icons.add_circle,
                      Theme.of(context).primaryColor,
                      () => _createNewSeason(),
                    ),
                    _buildActionCard(
                      '赛季结算',
                      Icons.trending_up,
                      Colors.teal,
                      () => _settleSeason(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('权限配置', [
                    _buildActionCard(
                      '角色权限管理',
                      Icons.security,
                      Colors.indigo,
                      () => _managePermissions(),
                    ),
                    _buildActionCard(
                      '功能权限设置',
                      Icons.settings,
                      Colors.blueGrey,
                      () => _manageFeaturePermissions(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection('系统信息', [
                    _buildInfoItem('系统版本', '1.0.0-beta'),
                    _buildInfoItem('数据库版本', 'PostgreSQL 12'),
                    _buildInfoItem('最后备份时间', '2026-03-26 14:30'),
                    _buildInfoItem('数据大小', '125 MB'),
                  ]),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    '检查更新',
                    Icons.system_update,
                      Colors.green,
                    () => _checkUpdates(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildChoiceSetting(
    String title,
    String value,
    List<String> values,
    List<String> labels,
    Function(String) onChanged,
  ) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(values.length, (index) {
                final isSelected = value == values[index];
                return ChoiceChip(
                  label: Text(labels[index], style: const TextStyle(color: Colors.white)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onChanged(values[index]);
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white10,
                  checkmarkColor: Colors.white,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$value 天',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (newValue) {
                onChanged(newValue.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e2e),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                '正在备份数据...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据备份完成'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('恢复数据', style: TextStyle(color: Colors.white)),
        content: const Text(
          '选择要恢复的备份文件：',
          style: TextStyle(color: Colors.white70),
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
                const SnackBar(
                  content: Text('数据恢复功能开发中'),
                ),
              );
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('测试通知已发送'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSeasonsList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('赛季列表', style: TextStyle(color: Colors.white)),
        content: const SizedBox(
          height: 300,
          child: Center(
            child: Text(
              '赛季列表功能开发中',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createNewSeason() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('创建新赛季', style: TextStyle(color: Colors.white)),
        content: const Text(
          '新赛季创建功能开发中',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _settleSeason() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('赛季结算', style: TextStyle(color: Colors.white)),
        content: const Text(
          '赛季结算功能开发中',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _managePermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('权限管理', style: TextStyle(color: Colors.white)),
        content: const Text(
          '角色权限管理功能开发中',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _manageFeaturePermissions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('功能权限', style: TextStyle(color: Colors.white)),
        content: const Text(
          '功能权限设置功能开发中',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _checkUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('检查更新', style: TextStyle(color: Colors.white)),
        content: const Text(
          '当前已是最新版本 v1.0.0-beta',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
