import 'package:flutter/material.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int _userPoints = 1234;
  final List<Map<String, dynamic>> _rewards = [
    {
      'id': 1,
      'name': '免作业卡',
      'description': '可免除一次作业',
      'points': 100,
      'type': 'privilege',
      'stock': -1,
      'icon': Icons.assignment_turned_in,
    },
    {
      'id': 2,
      'name': '座位优先权',
      'description': '下月座位选择优先',
      'points': 200,
      'type': 'privilege',
      'stock': 5,
      'icon': Icons.chair,
    },
    {
      'id': 3,
      'name': '表扬电话',
      'description': '班主任给家长打表扬电话',
      'points': 50,
      'type': 'privilege',
      'stock': -1,
      'icon': Icons.phone,
    },
    {
      'id': 4,
      'name': '奶茶券',
      'description': '一杯奶茶兑换券',
      'points': 300,
      'type': 'physical',
      'stock': 3,
      'icon': Icons.local_cafe,
    },
    {
      'id': 5,
      'name': '笔记本',
      'description': '精美笔记本一本',
      'points': 150,
      'type': 'physical',
      'stock': 20,
      'icon': Icons.book,
    },
    {
      'id': 6,
      'name': '班级徽章',
      'description': '优秀学生徽章',
      'points': 500,
      'type': 'virtual',
      'stock': 10,
      'icon': Icons.emoji_events,
    },
  ];

  void _showExchangeDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: Text('兑换 ${reward['name']}', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward['description'] != null)
              Text(reward['description'], style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('所需积分: ${reward['points']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            Text('当前积分: $_userPoints', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            if (_userPoints < reward['points'])
              const Text('积分不足', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消', style: TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('兑换申请已提交，等待班主任审核'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: const Text('确认兑换'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分商城'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 积分显示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const Text('我的积分', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text('$_userPoints', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 分类标签
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('全部', true),
                _buildCategoryChip('特权', false),
                _buildCategoryChip('实物', false),
                _buildCategoryChip('虚拟', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 商品列表
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _rewards.length,
              itemBuilder: (context, index) {
                return _buildRewardCard(_rewards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final canAfford = _userPoints >= reward['points'];
    
    return Card(
      color: const Color(0xFF1e1e2e),
      child: InkWell(
        onTap: () => _showExchangeDialog(reward),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Icon(reward['icon'], size: 60, color: Colors.white70),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward['name'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (reward['description'] != null)
                    Text(
                      reward['description'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${reward['points']} 积分',
                    style: TextStyle(
                      color: canAfford ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: canAfford ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          reward['type'] == 'privilege' ? '特权' : '实物',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      if (reward['stock'] >= 0 && reward['stock'] <= 5)
                        Text('仅剩${reward['stock']}份', style: const TextStyle(color: Colors.orange, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
