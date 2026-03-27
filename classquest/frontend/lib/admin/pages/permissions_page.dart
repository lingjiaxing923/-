import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';

class Permission {
  final String id;
  final String name;
  final String category;
  final String description;
  final List<String> roles; // 允许的角色
  final bool enabled;

  Permission({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.roles,
    required this.enabled,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      roles: List<String>.from(json['roles'] as List),
      enabled: json['enabled'] as bool,
    );
  }
}

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  bool _isLoading = false;
  Map<String, List<Permission>> _permissionsByCategory = {};
  final Map<String, String> _categoryIcons = {
    'points': 'stars',
    'users': 'people',
    'classes': 'class',
    'rewards': 'card_giftcard',
    'reports': 'assessment',
    'system': 'settings',
  };

  final Map<String, String> _categoryNames = {
    'points': '积分权限',
    'users': '用户权限',
    'classes': '班级权限',
    'rewards': '商城权限',
    'reports': '报表权限',
    'system': '系统权限',
  };

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/permissions');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        final permissionsList = (data['permissions'] as List)
            .map((p) => Permission.fromJson(p as Map<String, dynamic>))
            .toList();

        // 按类别分组
        Map<String, List<Permission>> grouped = {};
        for (var permission in permissionsList) {
          if (!grouped.containsKey(permission.category)) {
            grouped[permission.category] = [];
          }
          grouped[permission.category]!.add(permission);
        }

        setState(() {
          _permissionsByCategory = grouped;
        });
      }
    } catch (e) {
      print('加载权限失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePermission(String permissionId, bool enabled) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.put(
        '/permissions/$permissionId',
        body: {'enabled': enabled},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('权限设置已更新'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPermissions();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }

  Future<void> _saveRolePermissions() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/permissions/role-mapping',
        body: {},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('角色权限映射已保存'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  void _showPermissionDetail(Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                permission.name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                '功能描述:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                permission.description,
                style: const TextStyle(color: Colors.white),
                height: 1.5,
              ),
              const SizedBox(height: 16),
              const Text(
                '允许的角色:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: permission.roles.map((role) {
                  final roleLabels = {
                    'admin': '班主任',
                    'manager': '科代表',
                    'student': '学生',
                    'teacher': '任课教师',
                  };
                  final roleColors = {
                    'admin': Colors.purple,
                    'manager': Colors.orange,
                    'student': Colors.green,
                    'teacher': Colors.blue,
                  };

                  return Chip(
                    label: Text(roleLabels[role] ?? role),
                    avatar: CircleAvatar(
                      backgroundColor: roleColors[role] ?? Colors.grey,
                      child: Text(
                        (roleLabels[role] ?? role)[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    backgroundColor: (roleColors[role] ?? Colors.grey).withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                permission.enabled ? '当前状态: 已启用' : '当前状态: 已禁用',
                style: TextStyle(
                  color: permission.enabled ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!permission.enabled)
                const SizedBox(height: 8),
              if (!permission.enabled)
                Text(
                  '注意: 禁用后所有角色都将无法使用此功能',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _togglePermission(permission.id, !permission.enabled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: permission.enabled ? Colors.red : Colors.green,
            ),
            child: Text(permission.enabled ? '禁用' : '启用'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '权限配置',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPermissions,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveRolePermissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPermissionsList(),
    );
  }

  Widget _buildPermissionsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _permissionsByCategory.entries.map((entry) {
        final category = entry.key;
        final permissions = entry.value;
        final icon = _categoryIcons[category] ?? 'settings';
        final categoryName = _categoryNames[category] ?? category;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(icon, categoryName, permissions.length),
            const SizedBox(height: 16),
            ...permissions.map((permission) {
              return _buildPermissionCard(permission);
            }),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryHeader(IconData icon, String name, int count) {
    final enabledCount = permissions.where((p) => p.enabled).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$enabledCount/$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(Permission permission) {
    final enabled = permission.enabled;

    return Card(
      color: enabled ? const Color(0xFF1e1e2e) : const Color(0xFF2a2a3e),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPermissionDetail(permission),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: enabled ? Theme.of(context).primaryColor : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: enabled ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permission.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
