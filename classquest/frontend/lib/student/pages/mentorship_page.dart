import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/api_service.dart';

class MentorshipPage extends StatefulWidget {
  const MentorshipPage({super.key});

  @override
  State<MentorshipPage> createState() => _MentorshipPageState();
}

enum MentorshipType { mentor, mentee }

class _MentorshipPageState extends State<MentorshipPage> {
  MentorshipType _selectedType = MentorshipType.mentee;
  final List<Map<String, dynamic>> _applications = [];
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/mentorships/my');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _applications.clear();
          _applications.addAll(List<Map<String, dynamic>>.from(data['applications'] ?? []));
        });
      }
    } catch (e) {
      print('加载师徒申请失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showApplyDialog() {
    final TextEditingController mentorIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text(
          _selectedType == MentorshipType.mentor
              ? '招收徒弟'
              : '申请师傅',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: mentorIdController,
              decoration: InputDecoration(
                hintText: _selectedType == MentorshipType.mentor
                    ? '输入徒弟学号'
                    : '输入师傅学号',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF16213e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              '积分分配比例:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildRatioChip('10%', 10),
                _buildRatioChip('15%', 15),
                _buildRatioChip('20%', 20),
              ],
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
              try {
                final apiService = context.read<ApiService>();
                final response = await apiService.post('/mentorships/apply', body: {
                  'type': _selectedType.name,
                  'target_user_id': mentorIdController.text,
                  'ratio': 10,
                });
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('申请已提交，等待对方审核')),
                  );
                  Navigator.pop(context);
                  _loadApplications();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('申请失败: $e')),
                );
              }
            },
            child: const Text('提交申请'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioChip(String label, int value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      selected: false,
      onSelected: (selected) {},
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: const Color(0xFF16213e),
    );
  }

  Future<void> _approveApplication(int id) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post('/mentorships/$id/approve', body: {});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已通过申请')),
        );
        _loadApplications();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  Future<void> _rejectApplication(int id) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post('/mentorships/$id/reject', body: {});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已拒绝申请')),
        );
        _loadApplications();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '师徒结对',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTypeSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _applications.isEmpty
                    ? _buildEmptyState()
                    : _buildApplicationsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyDialog,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: Text(
          _selectedType == MentorshipType.mentor ? '招收徒弟' : '申请师傅',
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              label: '我的徒弟',
              type: MentorshipType.mentor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTypeButton(
              label: '我的师傅',
              type: MentorshipType.mentee,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({required String label, required MentorshipType type}) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
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
            _selectedType == MentorshipType.mentor
                ? Icons.group_add
                : Icons.person_search,
            size: 80,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedType == MentorshipType.mentor
                ? '还没有徒弟'
                : '还没有师傅',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedType == MentorshipType.mentor
                ? '点击右下角按钮招收徒弟'
                : '点击右下角按钮申请师傅',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final application = _applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status'] as String;
    final isPending = status == 'pending';

    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 24,
                  child: Text(
                    (application['partner_name'] as String)[0],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['partner_name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '学号: ${application['partner_username']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.percent,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '师傅获得徒弟积分的 ${application['ratio']}%',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '申请时间: ${application['created_at']}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveApplication(application['id']),
                      icon: const Icon(Icons.check),
                      label: const Text('同意'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectApplication(application['id']),
                      icon: const Icon(Icons.close),
                      label: const Text('拒绝'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = '待审核';
        break;
      case 'approved':
        color = Colors.green;
        label = '已通过';
        break;
      case 'rejected':
        color = Colors.red;
        label = '已拒绝';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
