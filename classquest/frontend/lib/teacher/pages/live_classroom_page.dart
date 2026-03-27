import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/services/websocket_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/widgets/danmaku_widget.dart';
import '../../shared/widgets/charts.dart';

class LiveClassroomPage extends StatefulWidget {
  const LiveClassroomPage({super.key});

  @override
  State<LiveClassroomPage> createState() => _LiveClassroomPageState();
}

class _LiveClassroomPageState extends State<LiveClassroomPage> {
  WebSocketService? _wsService;
  bool _danmakuEnabled = true;
  int _danmakuSpeed = 3;
  final List<DanmakuMessage> _danmakuMessages = [];
  final List<Map<String, dynamic>> _liveFeed = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user != null) {
      _wsService = WebSocketService();
      final connected = await _wsService!.connect(
        classId: user.classId ?? 1,
        userId: user.id,
        token: 'your-token-here', // TODO: 从AuthService获取
      );

      if (connected) {
        _wsService!.registerHandler('points_update', _handlePointsUpdate);
        _wsService!.registerHandler('notification', _handleNotification);
      }
    }
  }

  void _handlePointsUpdate(WebSocketMessage message) {
    final data = message.data;
    if (data != null) {
      final points = data['points'] as int;
      final userName = data['user_name'] as String;
      final reason = data['reason'] as String;
      final operatorName = data['operator_name'] as String;

      // 添加到弹幕
      if (_danmakuEnabled) {
        setState(() {
          _danmakuMessages.add(DanmakuMessage(
            content: '$reason ($operatorName)',
            points: points,
            userName: userName,
            color: points > 0 ? Colors.green : Colors.orange,
            timestamp: message.timestamp ?? DateTime.now().toString(),
          ));
        });
      }

      // 添加到实时动态
      setState(() {
        _liveFeed.insert(0, {
          'user_name': userName,
          'points': points,
          'reason': reason,
          'operator_name': operatorName,
          'timestamp': message.timestamp ?? DateTime.now().toString(),
        });
        if (_liveFeed.length > 20) {
          _liveFeed.removeLast();
        }
      });
    }
  }

  void _handleNotification(WebSocketMessage message) {
    final data = message.data;
    if (data != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['title']}: ${data['message']}'),
          backgroundColor: data['notification_type'] == 'warning'
              ? Colors.orange
              : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _wsService?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // 统计卡片
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            icon: Icons.people,
                            label: '班级人数',
                            value: '45',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            icon: Icons.star,
                            label: '总积分',
                            value: '12,580',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            icon: Icons.trending_up,
                            label: '今日加分',
                            value: '+156',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            icon: Icons.trending_down,
                            label: '今日扣分',
                            value: '-23',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 弹幕区域
                    _buildDanmakuSection(),
                    const SizedBox(height: 16),
                    // 实时动态
                    LiveFeedWidget(
                      feedItems: _liveFeed,
                      onItemTap: (item) {
                        // 点击动态项显示详情
                      },
                    ),
                    const SizedBox(height: 16),
                    // 排行榜预览
                    _buildLeaderboardPreview(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '🔴 实时课堂',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: Colors.red, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.group, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '三年二班',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.school, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '数学课',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                Icons.wifi,
                color: _wsService?.isConnected == true
                    ? Colors.green
                    : Colors.red,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                _wsService?.isConnected == true ? '已连接' : '未连接',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDanmakuSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '课堂弹幕',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DanmakuControlWidget(
              isEnabled: _danmakuEnabled,
              onToggle: (enabled) {
                setState(() {
                  _danmakuEnabled = enabled;
                });
              },
              speed: _danmakuSpeed,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_danmakuEnabled)
          DanmakuWidget(
            messages: _danmakuMessages,
            height: 200,
            showPoints: true,
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1e1e2e),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.comment_off,
                    size: 48,
                    color: Colors.white30,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '弹幕已关闭',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaderboardPreview() {
    final topStudents = [
      {'rank': 1, 'name': '张三', 'points': 1234},
      {'rank': 2, 'name': '李四', 'points': 1189},
      {'rank': 3, 'name': '王五', 'points': 1156},
      {'rank': 4, 'name': '赵六', 'points': 1098},
      {'rank': 5, 'name': '孙七', 'points': 1056},
    ];

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
                const Text(
                  '实时排行榜 TOP 5',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    '查看全部',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(topStudents.length, (index) {
              final student = topStudents[index];
              return _buildLeaderboardItem(student, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> student, int rank) {
    final isTopThree = rank <= 3;
    final medals = [Colors.amber, Colors.orange, Colors.brown];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTopThree
                  ? medals[rank - 1]
                  : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${student['points']}分',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
