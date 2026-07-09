class ProfileModel {
  final String id;
  final String fullName;
  final String course;
  final String batch;
  final String company;
  final String supervisor;
  final String qrCodeToken;
  final double requiredHours;
  final String startDate;
  final String? avatarPath;
  final String email;
  final String password;
  final String department;
  final double weeklyTargetHours;
  final int weekStartDay;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.course,
    required this.batch,
    required this.company,
    required this.supervisor,
    required this.qrCodeToken,
    required this.requiredHours,
    required this.startDate,
    this.avatarPath,
    this.email = '',
    this.password = '',
    this.department = '',
    this.weeklyTargetHours = 40,
    this.weekStartDay = 1,
  });

  factory ProfileModel.empty() => ProfileModel(
        id: 'default_user',
        fullName: 'Juan dela Cruz',
        course: 'BSIT',
        batch: 'Batch 2025',
        company: 'Not set',
        supervisor: 'Not set',
        qrCodeToken: 'intern_token_abc',
        requiredHours: 486,
        startDate: DateTime.now().toIso8601String(),
        email: 'intern@example.com',
        password: '',
        weeklyTargetHours: 40,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'role': '$course • $batch',
        'qr_code_token': qrCodeToken,
        'company': company,
        'supervisor': supervisor,
        'required_hours': requiredHours,
        'start_date': startDate,
        'avatar_path': avatarPath,
        'email': email,
        'password': password,
        'department': department,
        'weekly_target_hours': weeklyTargetHours,
        'week_start_day': weekStartDay,
      };

  factory ProfileModel.fromMap(Map<String, dynamic> m) {
    final role = (m['role'] as String?) ?? 'BSIT • Batch 2025';
    final parts = role.split('•');
    return ProfileModel(
      id: m['id'],
      fullName: m['full_name'],
      course: parts.isNotEmpty ? parts[0].trim() : 'BSIT',
      batch: parts.length > 1 ? parts[1].trim() : 'Batch 2025',
      company: m['company'] ?? 'Not set',
      supervisor: m['supervisor'] ?? 'Not set',
      qrCodeToken: m['qr_code_token'],
      requiredHours: (m['required_hours'] as num?)?.toDouble() ?? 486,
      startDate: m['start_date'] ?? DateTime.now().toIso8601String(),
      avatarPath: m['avatar_path'] as String?,
      email: m['email'] ?? '',
      password: m['password'] ?? '',
      department: m['department'] ?? '',
      weeklyTargetHours: (m['weekly_target_hours'] as num?)?.toDouble() ?? 40,
      weekStartDay: (m['week_start_day'] as int?) ?? 1,
    );
  }

  ProfileModel copyWith({
    String? fullName,
    String? course,
    String? batch,
    String? company,
    String? supervisor,
    double? requiredHours,
    String? avatarPath,
    bool clearAvatar = false,
    String? email,
    String? password,
    String? department,
    double? weeklyTargetHours,
    int? weekStartDay,
  }) =>
      ProfileModel(
        id: id,
        fullName: fullName ?? this.fullName,
        course: course ?? this.course,
        batch: batch ?? this.batch,
        company: company ?? this.company,
        supervisor: supervisor ?? this.supervisor,
        qrCodeToken: qrCodeToken,
        requiredHours: requiredHours ?? this.requiredHours,
        startDate: startDate,
        avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
        email: email ?? this.email,
        password: password ?? this.password,
        department: department ?? this.department,
        weeklyTargetHours: weeklyTargetHours ?? this.weeklyTargetHours,
        weekStartDay: weekStartDay ?? this.weekStartDay,
      );
}
