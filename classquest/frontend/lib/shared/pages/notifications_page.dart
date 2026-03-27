import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../shared/services/api_service.dart';

class NotificationData {
  final int id;
  final String type;
  final String title;
  final String content;
  final bool isRead;
  final String createdAt;
  final String? readAt;

  NotificationData({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      createdAt: json['created_at'] as String,
      readAt: json['read_at'] as String?,
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = false;
  bool _showUnreadOnly = false;
  List<NotificationData> _notifications = [];
  int _totalCount = 0;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get(
        '/notifications?unread_only=$_showUnreadOnly&limit=50',
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _notifications = (data['notifications'] as List)
              .map((n) => NotificationData.fromJson(n as Map<String, dynamic>))
              .toList();
          _totalCount = data['total_count'] as int;
          _unreadCount = data['unread_count'] as int;
        });
      }
    } catch (e) {
      print('加载通知失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/notifications/$notificationId/read',
        body: {},
      );
      if (response.statusCode == 200) {
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notificationId);
          if (index != -1) {
            _notifications[index] = NotificationData(
              id: _notifications[index].id,
              type: _notifications[index].type,
              title: _notifications[index].title,
              content: _notifications[index].content,
              isRead: true,
              createdAt: _notifications[index].createdAt,
              readAt: DateTime.now().toIso8601String(),
            );
            _unreadCount--;
          }
        });
      }
    } catch (e) {
      print('标记已读失败: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.post(
        '/notifications/mark-all-read',
        body: {},
      );
      if (response.statusCode == 200) {
        setState(() {
          for (var i = 0; i < _notifications.length; i++) {
            _notifications[i] = NotificationData(
              id: _notifications[i].id,
              type: _notifications[i].type,
              title: _notifications[i].title,
              content: _notifications[i].content,
              isRead: true,
              createdAt: _notifications[i].createdAt,
              readAt: DateTime.now().toIso8601String(),
            );
          }
          _unreadCount = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有通知已标记为已读')),
        );
      }
    } catch (e) {
      print('标记全部已读失败: $e');
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('删除通知', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要删除这条通知吗？',
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
              try {
                final apiService = context.read<ApiService>();
                final response = await apiService.delete(
                  '/notifications/$notificationId',
                );
                if (response.statusCode == 200) {
                  setState(() {
                    _notifications.removeWhere((n) => n.id == notificationId);
                    _totalCount--;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知已删除')),
                  );
                }
              } catch (e) {
                print('删除失败: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
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
          '通知中心',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.mark_email_read, color: Colors.white),
              label: const Text('全部已读', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
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
            '共 $_totalCount 条通知',
            style: TextStyle(color: Colors.white70),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_unreadCount 条未读',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          FilterChip(
            label: Text(
              '仅显示未读',
              style: const TextStyle(color: Colors.white),
            ),
            selected: _showUnreadOnly,
            onSelected: (selected) {
              setState(() {
                _showUnreadOnly = selected;
                _loadNotifications();
              });
            },
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white10,
            checkmarkColor: Colors.white,
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
            Icons.notifications_none,
            size: 80,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? '暂无未读通知' : '暂无通知',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '享受您的学习时光吧！',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification, index);
      },
    );
  }

  Widget _buildNotificationCard(NotificationData notification, int index) {
    final iconData = _getNotificationIcon(notification.type);
    final iconColor = _getNotificationColor(notification.type);

    return Card(
      color: notification.isRead ? const Color(0xFF1e1e2e) : const Color(0xFF2a2a3e),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          _showNotificationDetail(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                          onPressed: () => _deleteNotification(notification.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'exchange_approved':
        return Icons.check_circle;
      case 'exchange_rejected':
        return Icons.cancel;
      case 'appeal_processed':
        return Icons.gavel;
      case 'mentorship_approved':
        return Icons.group_add;
      case 'mentorship_rejected':
        return Icons.group_remove;
      case 'points_warning':
        return Icons.warning;
      case 'system_announcement':
        return Icons.announcement;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'exchange_approved':
      case 'mentorship_approved':
        return Colors.green;
      case 'exchange_rejected':
      case 'mentorship_rejected':
        return Colors.red;
      case 'appeal_processed':
        return Colors.orange;
      case 'points_warning':
        return Colors.yellow;
      case 'system_announcement':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}周前';
      } else {
        return DateFormat('MM-dd').format(dt);
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _showNotificationDetail(NotificationData notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1e1e2e),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 48,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
        ],
      ),
    );
  }
}
