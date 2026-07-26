import 'package:json_annotation/json_annotation.dart';

part 'profile_dtos.g.dart';

@JsonSerializable()
class ProfileDto {
  const ProfileDto({
    required this.accountId,
    required this.phone,
    required this.phoneVerified,
    required this.emailVerified,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  final String accountId;
  final String phone;
  final bool phoneVerified;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool emailVerified;

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);
}

/// PATCH body with omit-vs-null field presence (server: omit = unchanged).
class PatchProfileRequest {
  const PatchProfileRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.includeFirstName = false,
    this.includeLastName = false,
    this.includeEmail = false,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final bool includeFirstName;
  final bool includeLastName;
  final bool includeEmail;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (includeFirstName) {
      map['firstName'] = firstName;
    }
    if (includeLastName) {
      map['lastName'] = lastName;
    }
    if (includeEmail) {
      map['email'] = email;
    }
    return map;
  }
}
