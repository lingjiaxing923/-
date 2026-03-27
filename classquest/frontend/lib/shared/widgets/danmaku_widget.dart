import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:async';

class DanmakuMessage {
  final String content;
  final Color color;
  final int? points;
  final String? userName;
  final String timestamp;

  DanmakuMessage({
    required this.content,
    this.color = Colors.white,
    this.points,
    this.userName,
    required this.timestamp,
  });
}

class DanmakuWidget extends StatefulWidget {
  final List<DanmakuMessage> messages;
  final double height;
  final bool showPoints;

  const DanmakuWidget({
    super.key,
    required this.messages,
    this.height = 200,
    this.showPoints = true,
  });

  @override
  State<DanmakuWidget> createState() => _DanmakuWidgetState();
}

class _DanmakuWidgetState extends State<DanmakuWidget>
    with TickerProviderStateMixin {
  final List<_DanmakuItem> _items = [];
  final math.Random _random = math.Random();
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        // 更新所有弹幕的位置
        _items.removeWhere((item) => item.isOffScreen(widget.height));

        for (var item in _items) {
          item.update();
        }

        // 从消息队列中添加新弹幕
        if (widget.messages.isNotEmpty) {
          final message = widget.messages.first;
          _items.add(_DanmakuItem(
            message: message,
            startY: _random.nextDouble() * (widget.height - 40),
            speed: 2.0 + _random.nextDouble() * 2.0,
          ));
          widget.messages.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 背景网格效果
          CustomPaint(
            size: Size.infinite,
            painter: _GridPainter(),
          ),
          // 弹幕
          ..._items.map((item) => _buildDanmakuItem(item)),
          // 实时消息计数
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.message, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.messages.length + _items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanmakuItem(_DanmakuItem item) {
    return Positioned(
      top: item.y,
      left: item.x,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.message.color.withOpacity(0.9),
              item.message.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.message.color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.message.userName != null) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.message.userName![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              item.message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.showPoints && item.message.points != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.message.points! > 0
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.message.points! > 0 ? '+${item.message.points}' : '${item.message.points}',
                  style: TextStyle(
                    color: item.message.points! > 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DanmakuItem {
  final DanmakuMessage message;
  final double startY;
  final double speed;

  double x = 400; // 初始在屏幕右侧外
  double y = 0;

  _DanmakuItem({
    required this.message,
    required this.startY,
    required this.speed,
  }) : y = startY;

  void update() {
    x -= speed;
  }

  bool isOffScreen(double screenHeight) {
    return x < -300; // 完全移出屏幕左侧
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    // 绘制网格
    const gridSize = 40.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 实时动态列表组件
class LiveFeedWidget extends StatelessWidget {
  final List<Map<String, dynamic>> feedItems;
  final Function(Map<String, dynamic>)? onItemTap;

  const LiveFeedWidget({
    super.key,
    required this.feedItems,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.pulse, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '实时动态',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 动态列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: feedItems.length,
              itemBuilder: (context, index) {
                final item = feedItems[index];
                return _buildFeedItem(item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(Map<String, dynamic> item, int index) {
    final isAdd = (item['points'] as int) > 0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 50),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAdd
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAdd
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: InkWell(
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isAdd ? Colors.green : Colors.orange,
                radius: 20,
                child: Text(
                  (item['user_name'] as String)[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['user_name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['reason'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isAdd ? '+${item['points']}' : '${item['points']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isAdd ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isAdd ? Icons.add_circle : Icons.remove_circle,
                color: isAdd ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 弹幕开关控制组件
class DanmakuControlWidget extends StatelessWidget {
  final bool isEnabled;
  final Function(bool) onToggle;
  final int speed;

  const DanmakuControlWidget({
    super.key,
    required this.isEnabled,
    required this.onToggle,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1e2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            '弹幕设置',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '速度: $speed',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
