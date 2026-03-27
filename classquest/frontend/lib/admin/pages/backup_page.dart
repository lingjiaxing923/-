import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../shared/services/api_service.dart';

class BackupInfo {
  final String filename;
  final String backupName;
  final String createdAt;
  final String createdBy;
  final int fileSize;
  final String fileSizeMb;
  final String version;

  BackupInfo({
    required this.filename,
    required this.backupName,
    required this.createdAt,
    required this.createdBy,
    required this.fileSize,
    required this.fileSizeMb,
    required this.version,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      filename: json['filename'] as String,
      backupName: json['backup_name'] as String? ?? json['filename'],
      createdAt: json['created_at'] as String,
      createdBy: json['created_by'] as String? ?? '系统',
      fileSize: json['file_size'] as int,
      fileSizeMb: json['file_size_mb'] as double,
      version: json['version'] as String? ?? '未知',
    );
  }
}

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isLoading = false;
  bool _isCreatingBackup = false;
  List<BackupInfo> _backups = [];
  int _totalCount = 0;
  double _totalSizeMb = 0;

  bool _autoBackupEnabled = true;
  String _backupFrequency = 'daily'; // daily, weekly, monthly
  int _backupRetentionDays = 30;

  @override
  void initState() {
    super.initState();
    _loadBackups();
    _loadBackupSettings();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/backup/list');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _backups = (data['backups'] as List)
              .map((b) => BackupInfo.fromJson(b as Map<String, dynamic>))
              .toList();
          _totalCount = data['total_count'] as int;
          _totalSizeMb = data['total_size_mb'] as double;
        });
      }
    } catch (e) {
      print('加载备份列表失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBackupSettings() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/backup/settings');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _autoBackupEnabled = data['auto_backup_enabled'] as bool;
          _backupFrequency = data['backup_frequency'] as String;
          _backupRetentionDays = data['backup_retention_days'] as int;
        });
      }
    } catch (e) {
      print('加载备份设置失败: $e');
    }
  }

  Future<void> _createBackup() async {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('创建备份', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: '备份名称（可选）',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF16213e),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performBackup(nameController.text);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup(String? name) async {
    setState(() => _isCreatingBackup = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/backup/create',
        body: name != null ? {'backup_name': name} : {},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份创建成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份创建失败: $e')),
      );
    } finally {
      setState(() => _isCreatingBackup = false);
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('恢复备份', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备份名称: ${backup.backupName}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '创建时间: ${_formatDateTime(backup.createdAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '文件大小: ${backup.fileSizeMb} MB',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              '警告：恢复数据将覆盖当前数据！',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performRestore(backup.filename);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestore(String filename) async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/backup/restore/$filename',
        body: {},
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('数据恢复成功，恢复 ${data['restored_records']} 条记录'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据恢复失败: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('删除备份', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除备份"${backup.backupName}"吗？\n此操作不可恢复。',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(backup.filename);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(String filename) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.delete(
        '/backup/$filename',
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份删除成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  Future<void> _updateBackupSettings() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/backup/settings',
        body: {
          'auto_backup_enabled': _autoBackupEnabled,
          'backup_frequency': _backupFrequency,
          'backup_retention_days': _backupRetentionDays,
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份设置已更新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('设置更新失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '数据备份',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBackups,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBackupSettings(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _backups.isEmpty
                    ? _buildEmptyState()
                    : _buildBackupList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCreatingBackup ? null : _createBackup,
        backgroundColor: Theme.of(context).primaryColor,
        icon: _isCreatingBackup
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.backup),
        label: Text(_isCreatingBackup ? '备份中...' : '创建备份'),
      ),
    );
  }

  Widget _buildBackupSettings() {
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
          Row(
            children: [
              const Text(
                '备份设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  _buildQuickStat('总备份', '$_totalCount'),
                  const SizedBox(width: 16),
                  _buildQuickStat('总大小', '${_totalSizeMb.toStringAsFixed(2)} MB'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSettingCard(
                  '自动备份',
                  _autoBackupEnabled,
                  (value) => setState(() => _autoBackupEnabled = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFrequencySelector(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSliderSetting(
            '保留天数',
            _backupRetentionDays,
            1,
            90,
            (value) => setState(() => _backupRetentionDays = value),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _updateBackupSettings,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('保存设置', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.check_circle_outline,
            color: value ? Colors.green : Colors.white54,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
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
                Text(
                  value ? '已启用' : '已禁用',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备份频率',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFrequencyChip('每天', 'daily'),
              _buildFrequencyChip('每周', 'weekly'),
              _buildFrequencyChip('每月', 'monthly'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyChip(String label, String value) {
    final isSelected = _backupFrequency == value;

    return InkWell(
      onTap: () => setState(() => _backupFrequency = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无备份文件',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮创建第一个备份',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _backups.length,
      itemBuilder: (context, index) {
        final backup = _backups[index];
        return _buildBackupCard(backup, index);
      },
    );
  }

  Widget _buildBackupCard(BackupInfo backup, int index) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(
                  Icons.backup,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    backup.backupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '创建者: ${backup.createdBy}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(backup.createdAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.storage,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${backup.fileSizeMb.toStringAsFixed(2)} MB',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _restoreBackup(backup),
                  icon: const Icon(Icons.restore, color: Colors.blue, size: 20),
                  label: const Text('恢复', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteBackup(backup),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  label: const Text('删除', style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }
}
