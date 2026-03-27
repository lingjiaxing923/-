import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../shared/services/api_service.dart';

class Season {
  final int id;
  final String name;
  final String startDate;
  final String? endDate;
  final bool isActive;
  final String createdAt;

  Season({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      isActive: json['is_active'] == 1,
      createdAt: json['created_at'] as String,
    );
  }
}

class SeasonsPage extends StatefulWidget {
  const SeasonsPage({super.key});

  @override
  State<SeasonsPage> createState() => _SeasonsPageState();
}

class _SeasonsPageState extends State<SeasonsPage> {
  bool _isLoading = false;
  List<Season> _seasons = [];

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/seasons');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _seasons = (data['seasons'] as List)
              .map((s) => Season.fromJson(s as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('加载赛季列表失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createSeason() async {
    final nameController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;

    final result = await showDialog<DateTime?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1e1e2e),
            title: const Text('创建新赛季', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: '赛季名称',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF16213e),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('开始日期', style: TextStyle(color: Colors.white70)),
                    subtitle: Text(
                      startDate != null
                          ? DateFormat('yyyy-MM-dd').format(startDate!)
                          : '选择开始日期',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                      child: const Text('选择', style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                  ListTile(
                    title: const Text('结束日期（可选）', style: TextStyle(color: Colors.white70)),
                    subtitle: Text(
                      endDate != null
                          ? DateFormat('yyyy-MM-dd').format(endDate!)
                          : '选择结束日期',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                      child: const Text('选择', style: TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('取消', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, startDate);
                },
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      await _performCreateSeason(nameController.text, result!);
    }
  }

  Future<void> _performCreateSeason(String name, DateTime startDate) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post('/seasons', body: {
        'name': name,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      });
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('赛季创建成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSeasons();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建失败: $e')),
      );
    }
  }

  Future<void> _settleSeason(Season season) async {
    if (season.isActive) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1e1e2e),
          title: const Text('赛季结算', style: TextStyle(color: Colors.white)),
          content: const Text(
            '赛季结算将锁定当前赛季，所有积分将停止更新。\n确定要结算当前赛季吗？',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performSettle(season);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('确认结算'),
            ),
          ],
        ),
      );
      return;
    }

    // 非活跃赛季直接结算
    await _performSettle(season);
  }

  Future<void> _performSettle(Season season) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/seasons/${season.id}/settle',
        body: {},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('赛季结算成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSeasons();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('结算失败: $e')),
      );
    }
  }

  Future<void> _activateSeason(Season season) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('激活赛季', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要激活赛季"${season.name}"吗？\n这将停用当前活跃赛季。',
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
              await _performActivate(season);
            },
            child: const Text('确认激活'),
          ),
        ],
      ),
    );
  }

  Future<void> _performActivate(Season season) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/seasons/${season.id}/activate',
        body: {},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('赛季激活成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadSeasons();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('激活失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          '赛季管理',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSeasonsStats(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _seasons.isEmpty
                    ? _buildEmptyState()
                    : _buildSeasonsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSeason,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('创建赛季'),
      ),
    );
  }

  Widget _buildSeasonsStats() {
    final activeSeason = _seasons.where((s) => s.isActive).firstOrNull();
    final totalSeasons = _seasons.length;

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
      child: Row(
        children: [
          const Text(
            '赛季统计',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildQuickStat('总赛季', '$totalSeasons'),
              if (activeSeason != null) ...[
                const SizedBox(width: 16),
                _buildQuickStat('当前赛季', activeSeason!.name),
              ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无赛季',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮创建第一个赛季',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _seasons.length,
      itemBuilder: (context, index) {
        final season = _seasons[index];
        return _buildSeasonCard(season, index);
      },
    );
  }

  Widget _buildSeasonCard(Season season, int index) {
    final isActive = season.isActive;

    return Card(
      color: isActive ? const Color(0xFF2a2a3e) : const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(28),
                border: isActive
                    ? Border.all(color: Colors.green, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          season.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            '活跃',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(season.startDate),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.event_available,
                        size: 14,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        season.endDate != null ? _formatDate(season.endDate!) : '进行中',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (!isActive)
                  TextButton.icon(
                    onPressed: () => _activateSeason(season),
                    icon: const Icon(Icons.play_arrow, color: Colors.green, size: 20),
                    label: const Text('激活', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _settleSeason(season),
                    icon: const Icon(Icons.check_circle, color: Colors.orange, size: 20),
                    label: const Text('结算', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
