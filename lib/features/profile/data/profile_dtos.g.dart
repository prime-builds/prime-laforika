// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  accountId: json['accountId'] as String,
  phone: json['phone'] as String,
  phoneVerified: json['phoneVerified'] as bool,
  emailVerified: json['emailVerified'] as bool,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ProfileDtoToJson(ProfileDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'phone': instance.phone,
      'phoneVerified': instance.phoneVerified,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
    };
