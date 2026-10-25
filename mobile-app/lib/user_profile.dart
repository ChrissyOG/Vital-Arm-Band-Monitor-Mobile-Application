import 'package:flutter/material.dart';

enum UserRole { caregiver, fitness, relative, personal }

extension UserRoleDetails on UserRole {
  String get title => switch (this) {
    UserRole.caregiver => 'Caregiver',
    UserRole.fitness => 'Fitness tracking',
    UserRole.relative => 'Relative',
    UserRole.personal => 'Personal health',
  };

  String get description => switch (this) {
    UserRole.caregiver => 'Keep an eye on someone in your care.',
    UserRole.fitness => 'Follow activity, movement and heart rate.',
    UserRole.relative => 'Stay connected to a family member.',
    UserRole.personal => 'Keep your own health readings close.',
  };

  IconData get icon => switch (this) {
    UserRole.caregiver => Icons.volunteer_activism_outlined,
    UserRole.fitness => Icons.directions_run_rounded,
    UserRole.relative => Icons.diversity_1_rounded,
    UserRole.personal => Icons.favorite_border_rounded,
  };

  bool get monitorsSomeone =>
      this == UserRole.caregiver || this == UserRole.relative;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.monitoredName,
  });

  final String name;
  final String email;
  final UserRole role;
  final String monitoredName;
}
