class UserProfile {
  final String studentId;
  final String anonymizedCode;
  String fullName;
  String email;
  int gradeLevel;
  String school;
  String district;
  String avatarId;
  String? customAvatarUrl;
  String motivationalArchetype;
  String preferredGoal;

  UserProfile({
    required this.studentId,
    required this.anonymizedCode,
    required this.fullName,
    required this.email,
    required this.gradeLevel,
    required this.school,
    required this.district,
    required this.avatarId,
    this.customAvatarUrl,
    required this.motivationalArchetype,
    required this.preferredGoal,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      studentId: json['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
      anonymizedCode: json['anonymized_code'] as String? ?? 'STU_HASH_9A4F21',
      fullName: json['full_name'] as String? ?? 'Kavindu Dharmasena',
      email: json['email'] as String? ?? 'student@example.lk',
      gradeLevel: (json['grade_level'] as num?)?.toInt() ?? 10,
      school: json['school'] as String? ?? 'Central College, Kandy',
      district: json['district'] as String? ?? 'Central Province',
      avatarId: json['avatar_id'] as String? ?? 'fox_math',
      customAvatarUrl: json['custom_avatar_url'] as String?,
      motivationalArchetype: json['motivational_archetype'] as String? ?? 'Achiever',
      preferredGoal: json['preferred_goal'] as String? ?? 'TERM_TEST',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'anonymized_code': anonymizedCode,
      'full_name': fullName,
      'email': email,
      'grade_level': gradeLevel,
      'school': school,
      'district': district,
      'avatar_id': avatarId,
      'custom_avatar_url': customAvatarUrl,
      'motivational_archetype': motivationalArchetype,
      'preferred_goal': preferredGoal,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    int? gradeLevel,
    String? school,
    String? district,
    String? avatarId,
    String? customAvatarUrl,
    bool clearCustomAvatar = false,
    String? motivationalArchetype,
    String? preferredGoal,
  }) {
    return UserProfile(
      studentId: studentId,
      anonymizedCode: anonymizedCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      school: school ?? this.school,
      district: district ?? this.district,
      avatarId: avatarId ?? this.avatarId,
      customAvatarUrl: clearCustomAvatar ? null : (customAvatarUrl ?? this.customAvatarUrl),
      motivationalArchetype: motivationalArchetype ?? this.motivationalArchetype,
      preferredGoal: preferredGoal ?? this.preferredGoal,
    );
  }
}
