import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class VoiceSearchWidget extends StatefulWidget {
  final Function(String) onStudentSelected;
  final int? classId;
  final bool enabled;

  const VoiceSearchWidget({
    super.key,
    required this.onStudentSelected,
    this.classId,
    this.enabled = true,
  });

  @override
  State<VoiceSearchWidget> createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget> {
  bool _isRecording = false;
  bool _isSearching = false;
  String _searchText = '';
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;
  bool _voiceSupported = false;

  @override
  void initState() {
    super.initState();
    _checkVoiceSupport();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _checkVoiceSupport() async {
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get('/voice/settings');
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _voiceSupported = data['voice_enabled'] ?? false;
        });
      }
    } catch (e) {
      print('检查语音支持失败: $e');
    }
  }

  Future<void> _performVoiceSearch() async {
    if (!_voiceSupported) {
      _showVoiceNotSupportedDialog();
      return;
    }

    setState(() => _isRecording = true);
    _searchText = '🎤 正在聆听...';

    // 模拟语音识别（实际应该调用语音识别API）
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isRecording = false;
      _searchText = '张三';  // 模拟识别结果
    });

    // 执行搜索
    await _performSearch(_searchText);
  }

  Future<void> _performSearch(String keyword) async {
    setState(() => _isSearching = true);
    _searchText = keyword;

    try {
      final apiService = context.read<ApiService>();
      final params = {
        'limit': 10,
        if (classId != null) 'class_id': classId,
      };

      final response = await apiService.post(
        '/voice/search',
        body: {...params, 'keyword': keyword},
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['results'] ?? []);
        });
      }
    } catch (e) {
      print('搜索失败: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _onTextChanged(String text) {
    // 防抖处理
    _searchDebounce?.cancel();
    if (text.length > 0) {
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        _performTextSearch(text);
      });
    } else {
      setState(() {
        _searchText = text;
        _searchResults = [];
      });
    }
  }

  Future<void> _performTextSearch(String keyword) async {
    setState(() => _isSearching = true);

    try {
      final apiService = context.read<ApiService>();
      final params = {
        'limit': 10,
        if (classId != null) 'class_id': classId,
      };

      final response = await apiService.get(
        '/voice/students',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['students'] ?? []);
        });
      }
    } catch (e) {
      print('文本搜索失败: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showVoiceNotSupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e1e2e),
        title: const Text('语音搜索', style: TextStyle(color: Colors.white)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_off,
              size: 48,
              color: Colors.white30,
            ),
            const SizedBox(height: 16),
            Text(
              '当前环境不支持语音搜索功能',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '提示：您可以使用文本搜索功能',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
              fontSize: 12,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          if (_searchResults.isNotEmpty) _buildResultsList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索学生姓名或学号...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1e1e2e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: _isRecording
                      ? Colors.red
                      : Colors.white54,
                ),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            _searchText = '';
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: _onTextChanged,
            ),
          ),
          const SizedBox(width: 8),
          if (_voiceSupported)
            _buildVoiceButton()
          else
            _buildVoiceDisabledButton(),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return InkWell(
      onTap: _isRecording ? null : _performVoiceSearch,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _isRecording
              ? Colors.red.withOpacity(0.2)
              : Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isRecording
                ? Colors.red
                : Theme.of(context).primaryColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              _searchText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceDisabledButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.mic_off,
            color: Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 4),
          const Text(
            '语音',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final student = _searchResults[index];
          return _buildStudentItem(student);
        },
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> student) {
    return Card(
      color: const Color(0xFF1e1e2e),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 24,
          child: Text(
            student['name'][0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.badge,
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  student['username'],
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.school,
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  student['class_name'] ?? '未分组',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '${student['total_points']}分',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          widget.onStudentSelected(student['username']);
          setState(() {
            _searchResults.clear();
            _searchText = '';
          });
        },
      ),
    );
  }
}
