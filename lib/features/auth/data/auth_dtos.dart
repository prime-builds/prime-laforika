import 'package:json_annotation/json_annotation.dart';

part 'auth_dtos.g.dart';

@JsonSerializable()
class TokenPairDto {
  const TokenPairDto({
    required this.accessToken,
    required this.refreshToken,
    required this.accountId,
    this.hasPhone = false,
    this.hasEmail = false,
    this.maskedPhone,
    this.maskedEmail,
  });

  factory TokenPairDto.fromJson(Map<String, dynamic> json) =>
      _$TokenPairDtoFromJson(json);

  final String accessToken;
  final String refreshToken;
  final String accountId;
  final bool hasPhone;
  final bool hasEmail;
  final String? maskedPhone;
  final String? maskedEmail;

  Map<String, dynamic> toJson() => _$TokenPairDtoToJson(this);
}

@JsonSerializable()
class ChallengeCreatedDto {
  const ChallengeCreatedDto({
    required this.challengeId,
    required this.maskedDestination,
    required this.resendAvailableAt,
    required this.expiresAt,
  });

  factory ChallengeCreatedDto.fromJson(Map<String, dynamic> json) =>
      _$ChallengeCreatedDtoFromJson(json);

  final String challengeId;
  final String maskedDestination;
  final String resendAvailableAt;
  final String expiresAt;

  Map<String, dynamic> toJson() => _$ChallengeCreatedDtoToJson(this);
}

@JsonSerializable()
class AccountMeDto {
  const AccountMeDto({
    required this.accountId,
    required this.hasPhone,
    required this.hasEmail,
    this.maskedPhone,
    this.maskedEmail,
  });

  factory AccountMeDto.fromJson(Map<String, dynamic> json) =>
      _$AccountMeDtoFromJson(json);

  final String accountId;
  final bool hasPhone;
  final bool hasEmail;
  final String? maskedPhone;
  final String? maskedEmail;

  Map<String, dynamic> toJson() => _$AccountMeDtoToJson(this);
}

@JsonSerializable()
class SessionDto {
  const SessionDto({
    required this.sessionId,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isCurrent,
    this.deviceLabel,
    this.revoked = false,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);

  final String sessionId;
  final String createdAt;
  final String lastSeenAt;
  final bool isCurrent;
  final String? deviceLabel;
  final bool revoked;

  Map<String, dynamic> toJson() => _$SessionDtoToJson(this);
}

@JsonSerializable()
class FixtureMessageDto {
  const FixtureMessageDto({
    required this.id,
    required this.channel,
    required this.destinationNormalized,
    required this.purpose,
    required this.code,
    required this.createdAt,
  });

  factory FixtureMessageDto.fromJson(Map<String, dynamic> json) =>
      _$FixtureMessageDtoFromJson(json);

  final String id;
  final String channel;
  final String destinationNormalized;
  final String purpose;
  final String code;
  final String createdAt;

  Map<String, dynamic> toJson() => _$FixtureMessageDtoToJson(this);
}
