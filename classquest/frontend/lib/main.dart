import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/shared/services/api_service.dart';
import 'lib/shared/services/auth_service.dart';
import 'lib/shared/models/user.dart';
import 'lib/admin/pages/admin_home_page.dart';
import 'lib/manager/pages/manager_home_page.dart';
import 'lib/student/pages/student_home_page.dart';
import 'lib/teacher/pages/teacher_home_page.dart';
import 'lib/shared/pages/login_page.dart';

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
      routes: {
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const AdminHomePage(),
        '/manager': (context) => const ManagerHomePage(),
        '/student': (context) => const StudentHomePage(),
        '/teacher': (context) => const TeacherHomePage(),
      },
    );
  }
}
