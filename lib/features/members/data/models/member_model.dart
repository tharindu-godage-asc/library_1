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
        registeredDate: json['registeredDate'] as DateTime,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'fullName': fullName, 'email': email,
        'phoneNumber': phoneNumber, 'registeredDate': registeredDate, 'isActive': isActive,
      };

  Member toEntity() => Member(
        id: id, fullName: fullName, email: email,
        phoneNumber: phoneNumber, registeredDate: registeredDate, isActive: isActive,
      );

  factory MemberModel.fromEntity(Member m) => MemberModel(
        id: m.id, fullName: m.fullName, email: m.email,
        phoneNumber: m.phoneNumber, registeredDate: m.registeredDate, isActive: m.isActive,
      );
}