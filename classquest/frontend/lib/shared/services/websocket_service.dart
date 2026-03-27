import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class WebSocketMessage {
  final String type;
  final Map<String, dynamic>? data;
  final String? timestamp;

  WebSocketMessage({
    required this.type,
    this.data,
    this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (data != null) 'data': data,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}

class WebSocketService extends ChangeNotifier {
  static const String baseUrl = 'ws://localhost:8000/api/v1/ws';
  WebSocketChannel? _channel;
  bool _isConnected = false;
  int? _classId;
  int? _userId;
  String? _token;

  final List<WebSocketMessage> _messageHistory = [];
  final Map<String, Function(WebSocketMessage)> _messageHandlers = {};

  bool get isConnected => _isConnected;
  List<WebSocketMessage> get messageHistory => List.unmodifiable(_messageHistory);

  Future<bool> connect({
    required int classId,
    required int userId,
    required String token,
  }) async {
    try {
      _classId = classId;
      _userId = userId;
      _token = token;

      final uri = Uri.parse('$baseUrl?class_id=$classId&user_id=$userId&token=$token');

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _isConnected = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('WebSocket连接失败: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final wsMessage = WebSocketMessage.fromJson(json);

      _messageHistory.add(wsMessage);
      if (_messageHistory.length > 100) {
        _messageHistory.removeAt(0);
      }

      // 调用对应的消息处理器
      final handler = _messageHandlers[wsMessage.type];
      if (handler != null) {
        handler(wsMessage);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket消息解析失败: $e');
    }
  }

  void _onError(error) {
    debugPrint('WebSocket错误: $error');
    _isConnected = false;
    notifyListeners();
  }

  void _onDone() {
    debugPrint('WebSocket连接关闭');
    _isConnected = false;
    notifyListeners();
  }

  void sendMessage(WebSocketMessage message) {
    if (_channel != null && _isConnected) {
      final json = jsonEncode(message.toJson());
      _channel!.sink.add(json);
    }
  }

  void sendPing() {
    sendMessage(const WebSocketMessage(type: 'ping'));
  }

  void registerHandler(String messageType, Function(WebSocketMessage) handler) {
    _messageHandlers[messageType] = handler;
  }

  void unregisterHandler(String messageType) {
    _messageHandlers.remove(messageType);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _messageHistory.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

// WebSocketChannel的简单实现
class WebSocketChannel {
  final Stream<dynamic> stream;
  final WebSocketSink sink;

  WebSocketChannel(this.stream, this.sink);

  static WebSocketChannel connect(Uri uri) {
    final socket = io.WebSocket.connect(uri.toString());
    final stream = socket.map((event) => event.data);
    final sink = _WebSocketSink(socket);

    return WebSocketChannel(stream, sink);
  }

  void dispose() {
    sink.close();
  }
}

class _WebSocketSink implements WebSocketSink {
  final io.WebSocket _socket;

  _WebSocketSink(this._socket);

  @override
  void add(dynamic data) {
    _socket.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _socket.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<dynamic> stream) {
    return _socket.addStream(stream);
  }

  @override
  Future close([int? closeCode, String? closeReason]) {
    return _socket.close(closeCode, closeReason);
  }
}

// 导入io包中的WebSocket
import 'dart:io' as io;
