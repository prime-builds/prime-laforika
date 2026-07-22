// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPairDto _$TokenPairDtoFromJson(Map<String, dynamic> json) => TokenPairDto(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  accountId: json['accountId'] as String,
  hasPhone: json['hasPhone'] as bool? ?? false,
  hasEmail: json['hasEmail'] as bool? ?? false,
  maskedPhone: json['maskedPhone'] as String?,
  maskedEmail: json['maskedEmail'] as String?,
);

Map<String, dynamic> _$TokenPairDtoToJson(TokenPairDto instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'accountId': instance.accountId,
      'hasPhone': instance.hasPhone,
      'hasEmail': instance.hasEmail,
      'maskedPhone': instance.maskedPhone,
      'maskedEmail': instance.maskedEmail,
    };

ChallengeCreatedDto _$ChallengeCreatedDtoFromJson(Map<String, dynamic> json) =>
    ChallengeCreatedDto(
      challengeId: json['challengeId'] as String,
      maskedDestination: json['maskedDestination'] as String,
      resendAvailableAt: json['resendAvailableAt'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$ChallengeCreatedDtoToJson(
  ChallengeCreatedDto instance,
) => <String, dynamic>{
  'challengeId': instance.challengeId,
  'maskedDestination': instance.maskedDestination,
  'resendAvailableAt': instance.resendAvailableAt,
  'expiresAt': instance.expiresAt,
};

AccountMeDto _$AccountMeDtoFromJson(Map<String, dynamic> json) => AccountMeDto(
  accountId: json['accountId'] as String,
  hasPhone: json['hasPhone'] as bool,
  hasEmail: json['hasEmail'] as bool,
  maskedPhone: json['maskedPhone'] as String?,
  maskedEmail: json['maskedEmail'] as String?,
);

Map<String, dynamic> _$AccountMeDtoToJson(AccountMeDto instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'hasPhone': instance.hasPhone,
      'hasEmail': instance.hasEmail,
      'maskedPhone': instance.maskedPhone,
      'maskedEmail': instance.maskedEmail,
    };

SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => SessionDto(
  sessionId: json['sessionId'] as String,
  createdAt: json['createdAt'] as String,
  lastSeenAt: json['lastSeenAt'] as String,
  isCurrent: json['isCurrent'] as bool,
  deviceLabel: json['deviceLabel'] as String?,
  revoked: json['revoked'] as bool? ?? false,
);

Map<String, dynamic> _$SessionDtoToJson(SessionDto instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'createdAt': instance.createdAt,
      'lastSeenAt': instance.lastSeenAt,
      'isCurrent': instance.isCurrent,
      'deviceLabel': instance.deviceLabel,
      'revoked': instance.revoked,
    };

FixtureMessageDto _$FixtureMessageDtoFromJson(Map<String, dynamic> json) =>
    FixtureMessageDto(
      id: json['id'] as String,
      channel: json['channel'] as String,
      destinationNormalized: json['destinationNormalized'] as String,
      purpose: json['purpose'] as String,
      code: json['code'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$FixtureMessageDtoToJson(FixtureMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channel': instance.channel,
      'destinationNormalized': instance.destinationNormalized,
      'purpose': instance.purpose,
      'code': instance.code,
      'createdAt': instance.createdAt,
    };
