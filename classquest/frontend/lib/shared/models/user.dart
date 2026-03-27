class User {
  final int id;
  final String username;
  final String realName;
  final String role;
  final int? classId;
  final int? groupId;
  final int? subjectId;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.username,
    required this.realName,
    required this.role,
    this.classId,
    this.groupId,
    this.subjectId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      realName: json['real_name'],
      role: json['role'],
      classId: json['class_id'],
      groupId: json['group_id'],
      subjectId: json['subject_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String get roleDisplayName {
    switch (role) {
      case 'admin':
        return '班主任';
      case 'manager':
        return '科代表';
      case 'student':
        return '学生';
      case 'teacher':
        return '任课教师';
      default:
        return '未知';
    }
  }
}
