import '../../domain/entities/member.dart';

class MemberModel {
  const MemberModel({
    required this.id, required this.fullName, required this.email,
    required this.phoneNumber, required this.registeredDate, required this.isActive,
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final DateTime registeredDate;
  final bool isActive;

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        registeredDate: _parseDateTime(json['registeredDate']),
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'fullName': fullName, 'email': email,
        'phoneNumber': phoneNumber,
        'registeredDate': registeredDate.toIso8601String(),
        'isActive': isActive,
      };

  static DateTime _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  Member toEntity() => Member(
        id: id, fullName: fullName, email: email,
        phoneNumber: phoneNumber, registeredDate: registeredDate, isActive: isActive,
      );

  factory MemberModel.fromEntity(Member m) => MemberModel(
        id: m.id, fullName: m.fullName, email: m.email,
        phoneNumber: m.phoneNumber, registeredDate: m.registeredDate, isActive: m.isActive,
      );
}