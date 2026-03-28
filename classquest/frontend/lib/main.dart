import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final role = prefs.getString('role');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: ClassQuestApp(
        initialRoute: token != null ? _getRouteForRole(role) : '/login',
      ),
    ),
  );
}

String _getRouteForRole(String? role) {
  switch (role) {
    case 'admin':
      return '/admin';
    case 'manager':
      return '/manager';
    case 'student':
      return '/student';
    case 'teacher':
      return '/teacher';
    default:
      return '/login';
  }
}

class ClassQuestApp extends StatelessWidget {
  final String initialRoute;
  const ClassQuestApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassQuest',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const SimpleLoginPage());
          case '/admin':
            return MaterialPageRoute(builder: (_) => const SimpleAdminPage());
          case '/manager':
            return MaterialPageRoute(builder: (_) => const SimpleManagerPage());
          case '/student':
            return MaterialPageRoute(builder: (_) => const SimpleStudentPage());
          case '/teacher':
            return MaterialPageRoute(builder: (_) => const SimpleTeacherPage());
          default:
            return MaterialPageRoute(builder: (_) => const SimpleLoginPage());
        }
      },
    );
  }
}

// 简化的页面用于测试构建
class SimpleLoginPage extends StatelessWidget {
  const SimpleLoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录页')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('登录功能需要后端支持', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('当前为简化测试版本', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class SimpleAdminPage extends StatelessWidget {
  const SimpleAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理员页面')),
      body: const Center(child: Text('管理员功能需要后端API支持')),
    );
  }
}

class SimpleManagerPage extends StatelessWidget {
  const SimpleManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理员页面')),
      body: const Center(child: Text('管理员功能需要后端API支持')),
    );
  }
}

class SimpleStudentPage extends StatelessWidget {
  const SimpleStudentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学生页面')),
      body: const Center(child: Text('学生功能需要后端API支持')),
    );
  }
}

class SimpleTeacherPage extends StatelessWidget {
  const SimpleTeacherPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('教师页面')),
      body: const Center(child: Text('教师功能需要后端API支持')),
    );
  }
}

// 临时服务类用于测试
class ApiService extends ChangeNotifier {
  ApiService();

  @override
  void dispose() {
    super.dispose();
  }
}

class AuthService extends ChangeNotifier {
  AuthService();

  String getRole() {
    return 'student';
  }

  Future<bool> login(String username, String password) async {
    return true;
  }

  void logout() {
    // 登录逻辑
  }
}
