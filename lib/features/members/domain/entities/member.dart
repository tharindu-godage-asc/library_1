class Member {
  const Member({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.registeredDate,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime registeredDate;
  final bool isActive;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Member copyWith({String? fullName, String? email, String? phoneNumber}) {
    return Member(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      registeredDate: registeredDate,
      isActive: isActive,
    );
  }
}